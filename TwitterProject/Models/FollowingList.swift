//
//  FollowingList.swift
//  TwitterProject
//
//  Created by Amr Hossam on 18/02/2022.
//

import Foundation

struct FollowingList: Codable {
    let followers: [String]
    let following: [String]
}
