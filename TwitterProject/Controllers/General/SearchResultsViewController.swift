//
//  SearchResultsViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 18/02/2022.
//

import UIKit
import FirebaseAuth

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult()
}

class SearchResultsViewController: UIViewController {


    private var searchResults =  [User]()

    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        return tableView
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        searchResults = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    func update(with results: [User]) {

        searchResults = results
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }

    

}


extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultTableViewCell.identifier,
            for: indexPath) as? SearchResultTableViewCell
        else {
            return UITableViewCell()
        }
        let user = searchResults[indexPath.row]
        guard let userID = Auth.auth().currentUser?.uid else {return UITableViewCell()}
        if user.id == userID {
            let model = SearchResultViewModel(userID: user.id, displayName: user.displayName, username: user.username, avatarPath: user.avatarPath, followState: .owner)
            cell.configureWith(model: model)
        } else {
            DatabaseManager.shared.fetchFollowingListsFor(userID: userID) { result in
                switch result {
                case .success(let followList):
                    if followList.following.contains(user.id) {
                        let model = SearchResultViewModel(userID: user.id, displayName: user.displayName, username: user.username, avatarPath: user.avatarPath, followState: .followed)
                        cell.configureWith(model: model)
                    } else {
                        let model = SearchResultViewModel(userID: user.id, displayName: user.displayName, username: user.username, avatarPath: user.avatarPath, followState: .notFollowed)
                        cell.configureWith(model: model)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }

        cell.backgroundColor = .clear
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}


