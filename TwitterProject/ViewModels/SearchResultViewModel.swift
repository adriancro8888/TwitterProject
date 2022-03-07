//
//  SearchResultViewModel.swift
//  TwitterProject
//
//  Created by Amr Hossam on 18/02/2022.
//

import Foundation

enum FollowState {
    case owner
    case followed
    case notFollowed
}

struct SearchResultViewModel {
    let userID: String
    let displayName: String
    let username: String
    let avatarPath: String
    let followState: FollowState
}
