//
//  TweetViewModel.swift
//  TwitterProject
//
//  Created by Amr Hossam on 16/02/2022.
//

import Foundation

struct TweetViewModel {
    let id: String
    let userID: String
    let displayName: String
    let username: String
    let timestamp: Double
    let tweetTextContent: String
    let avatarPath: String
    let isLiked: Bool
    let isRetweeted: Bool
}
