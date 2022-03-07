//
//  TweetDetailsViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 16/02/2022.
//

import UIKit

class TweetDetailsViewController: UIViewController {

    
    var selectedTweet: TweetViewModel?
    var replies: [TweetViewModel] = [TweetViewModel]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        fetchReplies()
    }
    
    private func fetchReplies() {
        guard let selectedTweet = selectedTweet else {
            return
        }
        
        DatabaseManager.shared.fetchRepliesForTweetWith(id: selectedTweet.id) { [weak self] result in
            switch result {
                case .success(let tweets):
                    self?.replies = tweets
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.frame
    }

    
}

extension TweetDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            
            return replies.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as? TweetTableViewCell,
        let tweet = selectedTweet else {
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            cell.configureWith(model: tweet)
            
        } else {
            cell.configureWith(model: replies[indexPath.row])
        }
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = TweetDetailsViewController()
        if indexPath.section == 0 {
            guard let selectedTweet = selectedTweet else {
                return
            }
            vc.selectedTweet = selectedTweet
        } else {
            vc.selectedTweet = replies[indexPath.row]
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension TweetDetailsViewController: TweetTableViewCellDelegate {
    
    func tweetTableViewCellTappedReply(_ cell: TweetTableViewCell, indexPath: IndexPath) {
        let vc = TweetComposerViewController()
        if indexPath.section == 0 {
            vc.parentReference = selectedTweet?.id
            vc.referencedUser = selectedTweet?.username
        } else {
            vc.parentReference = replies[indexPath.row].id
            vc.referencedUser = replies[indexPath.row].username
        }
        vc.isReply = true
        vc.configureAsReply()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tweetTableViewCellTappedRetweet(_ cell: TweetTableViewCell, indexPath: IndexPath) {
        
        var tweetId: String?
        if indexPath.section == 0 {
            tweetId = selectedTweet?.id
        } else {
            tweetId = replies[indexPath.row].id
        }
        if cell.isRetweeted {
            DatabaseManager.shared.dispatchUnretweetRequestFor(tweetID: tweetId!) { result in
                switch result {
                case .success():
                    cell.configureAsUnretweeted()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        } else {
            DatabaseManager.shared.dispatchRetweetRequestFor(tweetID: tweetId!) { result in
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
        
        var tweetId: String?
        if indexPath.section == 0 {
            tweetId = selectedTweet?.id
        } else {
            tweetId = replies[indexPath.row].id
        }
        if cell.isLiked {
            DatabaseManager.shared.dispatchUnlikeRequestFor(tweetID: tweetId!) { result in
                switch result {
                case .success():
                    cell.configureAsUnliked()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        } else {
            DatabaseManager.shared.dispatchLikeRequestFor(tweetID: tweetId!) { result in
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
        var userId: String?
        if indexPath.section == 0 {
            userId = selectedTweet?.userID
        } else {
            userId = replies[indexPath.row].userID
        }
        
        DatabaseManager.shared.getUserWith(userID: userId!) { [weak self] result in
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
    

    
    
}
