//
//  Tweet.swift
//  TwitterProject
//
//  Created by Amr Hossam on 15/02/2022.
//

import Foundation
import Firebase

struct Tweet: Codable {
    var id: String
    let timestamp: Double
    let authorID: String
    let tweetTextContent: String
    let likesCount: Int
    let mediaContent: [URL]?
    let likers: [String]?
    let isReply: Bool
    let retweetCount: Int
    let retweeters: [String]?
    let parentReference: String?
}


extension Tweet {
    
    var dictionary: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
