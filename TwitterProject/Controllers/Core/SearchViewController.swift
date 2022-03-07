//
//  SearchViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import UIKit

class SearchViewController: UIViewController {

    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: SearchResultsViewController())
        searchController.searchBar.placeholder = "Search by Username"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.definesPresentationContext = true
        return searchController
    }()

    
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
}



extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.count > 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        
        DatabaseManager.shared.queryUserWith(username: query) { result in
            switch result {
            case .success(let user):
                resultsController.update(with: [user])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


