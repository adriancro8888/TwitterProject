//
//  HomeViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    
    private var tweets: [TweetViewModel] = [TweetViewModel]()
    
    private let tweetComposeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 35
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.tintColor = .white
        return button
    }()
    
    
    private let homeTweetsTable: UITableView = {
        let table = UITableView()
        table.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return table
    }()
    
    private let refreshControl: UIRefreshControl = {
        let controller = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        return controller
    }()
    
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        guard let userID = Auth.auth().currentUser?.uid else {return UIImageView()}
        DatabaseManager.shared.getUserWith(userID: userID) { [weak self] result in
            switch result {
            case .success(let user):
                let urlString = user.avatarPath
                imageView.sd_setImage(with: URL(string: urlString))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return imageView
    }()
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(homeTweetsTable)
        view.addSubview(tweetComposeButton)
        homeTweetsTable.delegate = self
        homeTweetsTable.dataSource = self
        prepareNavbar()
        configureConstraints()
        tweetComposeButton.addTarget(self, action: #selector(didTapComposeTweetButton), for: .touchUpInside)
        homeTweetsTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc private func didPullToRefresh() {
        DatabaseManager.shared.fetchTweetsFromUserTimeline(as: .initial) { [weak self] result in
            switch result {
            case .success(let retreivedTweets):
                self?.tweets = retreivedTweets
                DispatchQueue.main.async {
                    self?.homeTweetsTable.reloadData()
                    self?.refreshControl.endRefreshing()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func didTapComposeTweetButton() {
        let vc = UINavigationController(rootViewController: TweetComposerViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func prepareNavbar() {
        let twitterLogoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        twitterLogoImageView.contentMode = .scaleAspectFill
        twitterLogoImageView.image = UIImage(named: "twitterLogo")
        let mview = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        mview.addSubview(twitterLogoImageView)
        navigationItem.titleView = mview
        
        

        let uview = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        uview.addSubview(avatarImageView)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: uview)
        navigationItem.leftBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfile)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "flame"), style: .plain, target: self, action: #selector(didTapLogout))
    }
    
    @objc private func didTapProfile() {
        let vc = ProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapLogout() {
        do {
            try Auth.auth().signOut()
            handleAuth()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeTweetsTable.frame = view.frame
    }
    
    
    
    private func handleWelcoming() {
        guard let id = Auth.auth().currentUser?.uid else {return}
        DatabaseManager.shared.getUserWith(userID: id) { [weak self] result in
            switch result {
            case .success(let user):
                if !user.isWelcomed {
                    let innerVC = ProfileFormViewController()
                    innerVC.title = "Setup your profile"
                    let vc = UINavigationController(rootViewController: innerVC)
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                } else {
                    if self?.tweets.count == 0 {
                        self?.initialTweetsFetching()
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleAuth() {
        if Auth.auth().currentUser == nil {
            let vc = UINavigationController(rootViewController: WelcomeViewController())
            vc.modalPresentationStyle = .fullScreen
            navigationController?.present(vc, animated: true)
        } else {
            handleWelcoming()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleAuth()
    }
    
    
    
    private func configureConstraints() {
        
        let tweetComposeButtonConstraints = [
            tweetComposeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            tweetComposeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            tweetComposeButton.widthAnchor.constraint(equalToConstant: 70),
            tweetComposeButton.heightAnchor.constraint(equalToConstant: 70)
        ]
        
        NSLayoutConstraint.activate(tweetComposeButtonConstraints)
    }

    
    
    private func initialTweetsFetching() {
        DatabaseManager.shared.fetchTweetsFromUserTimeline(as: .initial){ [weak self] result in
            switch result {
            case .success(let tweets):
                DispatchQueue.main.async {
                    self?.tweets = tweets
                    self?.homeTweetsTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource, TweetTableViewCellDelegate {
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
        
        let tweetId = tweets[indexPath.row].id
        
        if cell.isLiked {
            DatabaseManager.shared.dispatchUnlikeRequestFor(tweetID: tweetId) { result in
                switch result {
                case .success():
                    cell.configureAsUnliked()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        } else {
            DatabaseManager.shared.dispatchLikeRequestFor(tweetID: tweetId) { result in
                switch result {
                case .success():
                    cell.configureAsLiked()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        

        
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
        print(tweets[indexPath.row].displayName)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as? TweetTableViewCell else {
            return UITableViewCell()
        }
        cell.configureWith(model: tweets[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = TweetDetailsViewController()
        vc.selectedTweet = tweets[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
