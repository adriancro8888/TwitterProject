//
//  User.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import Foundation

struct User: Codable {
    let id: String
    let username: String
    let email: String
    let birthday: String
    let createdOn: String
    let displayName: String
    let followingCount: Int
    let followersCount: Int
    let bio: String
    let isWelcomed: Bool
    let avatarPath: String
}


extension User {
    init(id:String, email: String) {
        self.email = email
        self.id = id
        self.username = ""
        self.birthday = ""
        self.createdOn = Date().formatted(date: .complete, time: .complete)
        self.displayName = ""
        self.followersCount = 0
        self.followingCount = 0
        self.bio = ""
        self.isWelcomed = false
        self.avatarPath = ""
    }
    
    var dictionary: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
