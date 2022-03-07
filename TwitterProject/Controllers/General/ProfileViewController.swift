//
//  ProfileViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import UIKit
import FirebaseAuth
import SDWebImage

class ProfileViewController: UIViewController {


    private var tweets: [TweetViewModel] = [TweetViewModel]()
    var user: User?
    
    private let profileFeedTable: UITableView = {
        let table = UITableView()
        table.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return table
    }()
    
    fileprivate func configureHeaderView(_ vc: ProfileTableHeaderView) {
        if let user = user {
            vc.isOwner = false
            vc.userID = user.id
            vc.configureHeader()
        } else {
            vc.isOwner = true
            guard let userID = Auth.auth().currentUser?.uid else {return}
            vc.userID = userID
            vc.configureHeader()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        view.addSubview(profileFeedTable)
        profileFeedTable.delegate = self
        profileFeedTable.dataSource = self
        let vc = ProfileTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 420))
        vc.delegate = self
        configureHeaderView(vc)
        profileFeedTable.tableHeaderView = vc
        fetchTweets()
    }
    
    private func fetchTweets() {
        
        DatabaseManager.shared.fetchTweetsForCurrent(user: user) { [weak self] result in
            switch result {
            case .success(let tweets):
                self?.tweets = tweets
                DispatchQueue.main.async {
                    self?.profileFeedTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileFeedTable.frame = view.frame
    }
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as? TweetTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configureWith(model: tweets[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = TweetDetailsViewController()
        vc.selectedTweet = tweets[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: ProfileTableHeaderViewDelegate, TweetTableViewCellDelegate {

    func tweetTableViewCellTappedReply(_ cell: TweetTableViewCell, indexPath: IndexPath) {
        let vc = TweetComposerViewController()
        vc.parentReference = tweets[indexPath.row].id
        vc.referencedUser = tweets[indexPath.row].username
        vc.isReply = true
        vc.configureAsReply()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tweetTableViewCellTappedRetweet(_ cell: TweetTableViewCell, indexPath: IndexPath) {
        let tweetId = tweets[indexPath.row].id
        
        if cell.isRetweeted {
            DatabaseManager.shared.dispatchUnretweetRequestFor(tweetID: tweetId) { result in
                switch result {
                case .success():
                    cell.configureAsUnretweeted()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        } else {
            DatabaseManager.shared.dispatchRetweetRequestFor(tweetID: tweetId) { result in
                switch result {
                case .success():
                    cell.configureAsRetweeted()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
       
    }
    
    func tweetTableViewCellTappedLike(_ cell: TweetTableViewCell, indexPath: IndexPath) {
        
    }
    
    func tweetTableViewCellTappedShare(_ cell: TweetTableViewCell, tweetTextContent: String) {

        let shareSheetVC = UIActivityViewController(
            activityItems: [
                tweetTextContent
            ],
            applicationActivities: nil)
        
        present(shareSheetVC, animated: true)
    }
    
    func tweetTableViewCellTappedAvatar(_ tweetTableViewCell: TweetTableViewCell) {

        guard let indexPath = tweetTableViewCell.indexPath else {
            return
        }
        DatabaseManager.shared.getUserWith(userID: tweets[indexPath.row].userID) { [weak self] result in
            switch result {
            case .success(let user):
                let vc = ProfileViewController()
                vc.user = user

                self?.navigationController?.pushViewController(vc, animated: true)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func profileTableHeaderViewDidTapEditProfile(_ header: ProfileTableHeaderView) {
        let vc = ProfileFormViewController()
        vc.title = "Edit Profile"
        navigationController?.pushViewController(vc, animated: true)
    }
}
