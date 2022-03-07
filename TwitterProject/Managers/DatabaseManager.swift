//
//  DatabaseManager.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import Foundation
import FirebaseDatabase
import Firebase
import FirebaseFirestoreSwift



enum TimelineRequest {
    case initial
    case timestamped
}

enum FirestoreError: Error {
    case failedToInsertUser
    case failedToGetUser
    case failedToUpdate
    case failedToDispatchTweet
    case failedToFetchTweets
    case failedToFetchLists
    case failedToFollow
    case failedToUnfollow
    case failedToLike
    case failedToUnlike
}


class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let database = Firestore.firestore()

    func insertUserRecordToDatabaseWith(email: String, completion: @escaping (Result<Void, Error>)->Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let userRecord = database.collection("users").document(userID)
        let user = User(id: userID, email: email)
        guard let data = user.dictionary else {
            return
        }
        userRecord.setData(data) { [weak self] error in
            if error == nil {
                self?.database.collection("followingLists").document(userID).setData(["following":["\(userID)"], "followers": []]) { error in
                    completion(.success(()))
                }

            } else {
                completion(.failure(FirestoreError.failedToInsertUser))
            }
        }
    }
    
    
    func getUserWith(userID: String, completion: @escaping (Result<User, Error>) -> Void){

        database.collection("users").document(userID).getDocument { result, error in
            guard let document = result, error == nil else {
                completion(.failure(FirestoreError.failedToGetUser))
                return
            }
            
            do {
                guard let user = try document.data(as: User.self) else {return}
                completion(.success(user))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateRecordForUserWith(model: ProfileFormViewModel,completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        database.collection("users").document(userID).getDocument { result, error in
            guard let document = result, error == nil else {
                completion(.failure(FirestoreError.failedToGetUser))
                return
            }
            
            document.reference.updateData(
                [
                    "displayName": model.name,
                    "username": model.username,
                    "email": model.email,
                    "isWelcomed": model.isWelcomed,
                    "birthday": model.birthday,
                    "avatarPath": model.avatarPath,
                    "bio": model.bio
                ]
            ) { error in
                if error != nil {
                    completion(.failure(FirestoreError.failedToUpdate))
                    print("Error updating fields")
                } else {
                    completion(.success(()))
                    
                }
            }
            
        }
    }
    
    func dispatchTweetToStoreWith(model: Tweet, completion: @escaping (Result<Void, Error>) -> Void) {
        let doc = database.collection("tweets").document()
        var tweet = model
        tweet.id = doc.documentID
        guard let tweetDic = tweet.dictionary else {
            return
        }
        doc.setData(tweetDic) { error in
            if error != nil {
                completion(.failure(FirestoreError.failedToDispatchTweet))
                return
            }
            completion(.success(()))
            return
        }
    }
    
    
    func fetchTweetsForCurrent(user: User?, completion: @escaping (Result<[TweetViewModel], Error>)->Void) {
        
        var query: Query?
        var userID: String?
        if let user = user {
            query = database.collection("tweets").whereField("authorID", in: [user.id]).whereField("isReply", isEqualTo: false)
            userID = user.id
        } else {
            guard let localUserID = Auth.auth().currentUser?.uid else {return}
            query = database.collection("tweets").whereField("authorID", in: [localUserID]).whereField("isReply", isEqualTo: false)
            userID = localUserID
        }
        
        query?.order(by: "timestamp", descending: true).limit(to: 20).getDocuments { result, error in
                
                guard let result = result, error == nil else {
                    return
                }
                
                var tweets: [Tweet] = [Tweet]()
                do {
                    try result.documents.forEach { doc in
                        guard let tweet = try doc.data(as: Tweet.self) else {
                            return
                        }
                        tweets.append(tweet)
                    }
                }
                catch {
                    completion(.failure(FirestoreError.failedToFetchTweets))
                }
                var tweetViewModels: [TweetViewModel] = [TweetViewModel]()
                for tweet in tweets {
                    DatabaseManager.shared.getUserWith(userID: tweet.authorID) { response in
                        switch response {
                        case .success(let user):
                            guard let userID = userID else {
                                return
                            }
                            guard let myAccountId = Auth.auth().currentUser?.uid else {return}
                            tweetViewModels.append(TweetViewModel(id: tweet.id, userID: userID, displayName: user.displayName, username: user.username, timestamp: tweet.timestamp, tweetTextContent: tweet.tweetTextContent, avatarPath: user.avatarPath, isLiked: (tweet.likers?.contains(myAccountId))!, isRetweeted: (tweet.retweeters?.contains(myAccountId))!))
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                        completion(.success(tweetViewModels))
                    }
                }
        }
    }
    
    
    func fetchFollowingListsFor(userID: String, completion: @escaping (Result<FollowingList, Error>) -> Void) {
        database.collection("followingLists").document(userID).getDocument { result, error in
            guard let document = result, error == nil else {
                completion(.failure(FirestoreError.failedToFetchLists))
                return
            }
            
            do {
                guard let list = try document.data(as: FollowingList.self) else {return}
                completion(.success(list))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchTweetsFromUserTimeline(as type: TimelineRequest, completion: @escaping (Result<[TweetViewModel], Error>)-> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        fetchFollowingListsFor(userID: userID) { [weak self] result in
            switch result {
            case .success(let list):
                let query: Query?
    
                switch type {
                    case .initial:
                    query = self?.database.collection("tweets").whereField("authorID", in: list.following).order(by: "timestamp", descending: true).whereField("isReply", isEqualTo: false)
                    case .timestamped:
                    query = self?.database.collection("tweets").whereField("authorID", in: list.following).order(by: "timestamp", descending: true).whereField("isReply", isEqualTo: false)
                }
                query?.getDocuments { result, error in
                    guard let result = result, error == nil else {
                        return
                    }
                    var tweets: [Tweet] = [Tweet]()
                    do {
                        try result.documents.forEach { doc in
                            guard let tweet = try doc.data(as: Tweet.self) else {
                                return
                            }
                            tweets.append(tweet)
                        }
                    }
                    catch {
                        completion(.failure(FirestoreError.failedToFetchTweets))
                    }
                    var tweetViewModels: [TweetViewModel] = [TweetViewModel]()
                    for tweet in tweets {
                        DatabaseManager.shared.getUserWith(userID: tweet.authorID) { response in
                            switch response {
                            case .success(let user):
                                guard let myAccountId = Auth.auth().currentUser?.uid else {return}
                                tweetViewModels.append(TweetViewModel(id: tweet.id, userID: tweet.authorID, displayName: user.displayName, username: user.username, timestamp: tweet.timestamp, tweetTextContent: tweet.tweetTextContent, avatarPath: user.avatarPath, isLiked: (tweet.likers?.contains(myAccountId))!, isRetweeted: (tweet.retweeters?.contains(myAccountId))!))
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                            tweetViewModels = tweetViewModels.sorted(by: {
                                $0.timestamp > $1.timestamp
                            })
                            completion(.success(tweetViewModels))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func queryUserWith(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        database.collection("users").whereField("username", isEqualTo: username).getDocuments { result, error in
            guard let docs = result?.documents, error == nil else {
                return
            }
            
            do {
                guard let user = try docs.first?.data(as: User.self) else {
                    completion(.failure(FirestoreError.failedToGetUser))
                    return
                }
                completion(.success(user))
            } catch {
                completion(.failure(FirestoreError.failedToGetUser))
            }
        }
    }
    
    
    func dispatchFollowRequestFor(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userIDPath = Auth.auth().currentUser?.uid else {return}
        database.collection("followingLists").document(userIDPath).getDocument { [weak self] documents, error in
            guard let docs = documents, error == nil else {
                return
            }
            do {
                guard let followingList = try docs.data(as: FollowingList.self) else {
                    completion(.failure(FirestoreError.failedToFollow))
                    return
                }
                var newList = followingList.following
                newList.append(userID)
                self?.database.collection("followingLists").document(userIDPath).setData(["following" : newList, "followers": followingList.followers]) { error in
                    self?.database.collection("users").document(userIDPath).updateData(["followingCount" : FieldValue.increment(Int64(1))])
                    if error == nil {
                        self?.database.collection("followingLists").document(userID).getDocument(completion: { [weak self] documents, error in
                            guard let docs = documents, error == nil else {
                                return
                            }
                            do {
                                guard let followingList = try docs.data(as: FollowingList.self) else {
                                    completion(.failure(FirestoreError.failedToFollow))
                                    return
                                }
                                var newList = followingList.followers
                                newList.append(userIDPath)
                                self?.database.collection("followingLists").document(userID).setData(["following": followingList.following, "followers": newList]) { error in
                                    if error == nil {
                                        self?.database.collection("users").document(userID).updateData(["followersCount" : FieldValue.increment(Int64(1))])

                                        completion(.success(()))
                                    } else {
                                        completion(.failure(FirestoreError.failedToFollow))
                                    }
                                }
                            } catch {
                                completion(.failure(FirestoreError.failedToFollow))
                            }
                        })
                    }
                }
            } catch {
                completion(.failure(FirestoreError.failedToFollow))
            }
        }
    }
    
    func dispatchUnfollowRequestFor(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userIDPath = Auth.auth().currentUser?.uid else {return}
        database.collection("followingLists").document(userIDPath).getDocument { [weak self] documents, error in
            guard let docs = documents, error == nil else {
                return
            }
            do {
                guard let followingList = try docs.data(as: FollowingList.self) else {
                    completion(.failure(FirestoreError.failedToFollow))
                    return
                }
                var newList = followingList.following
                newList.remove(at: newList.firstIndex(of: userID)!)
                self?.database.collection("followingLists").document(userIDPath).setData(["following" : newList, "followers": followingList.followers]) { error in
                    if error == nil {
                        self?.database.collection("users").document(userIDPath).updateData(["followingCount" : FieldValue.increment(Int64(-1))])
                        self?.database.collection("followingLists").document(userID).getDocument(completion: { [weak self] documents, error in
                            guard let docs = documents, error == nil else {
                                return
                            }
                            do {
                                guard let followingList = try docs.data(as: FollowingList.self) else {
                                    completion(.failure(FirestoreError.failedToFollow))
                                    return
                                }
                                var newList = followingList.followers
                                newList.remove(at: newList.firstIndex(of: userIDPath)!)
                                self?.database.collection("followingLists").document(userID).setData(["following": followingList.following, "followers": newList]) { error in
                                    if error == nil {
                                        self?.database.collection("users").document(userID).updateData(["followersCount" : FieldValue.increment(Int64(-1))])
                                        completion(.success(()))
                                    } else {
                                        completion(.failure(FirestoreError.failedToFollow))
                                    }
                                }
                            } catch {
                                completion(.failure(FirestoreError.failedToFollow))
                            }
                        })
                    }
                }
            } catch {
                completion(.failure(FirestoreError.failedToFollow))
            }
        }
    }
    
    func dispatchLikeRequestFor(tweetID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        database.collection("tweets").document(tweetID).setData(["likers":[userId]], merge: true) { [weak self] error in
            if error == nil {
                self?.database.collection("tweets").document(tweetID).updateData(["likesCount" : FieldValue.increment(Int64(1))])
                completion(.success(()))
            } else {
                completion(.failure(FirestoreError.failedToLike))
            }
        }
    }
    
    func dispatchUnlikeRequestFor(tweetID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        database.collection("tweets").document(tweetID).getDocument { [weak self] result, error in
            if error == nil {
                do {
                    guard let tweet = try result?.data(as: Tweet.self),
                          let likerIndex = tweet.likers?.firstIndex(of: userId) else {return}
                    var likers:[String] = tweet.likers!
                    likers.remove(at: likerIndex)
                    self?.database.collection("tweets").document(tweetID).updateData(["likers": likers]) { error in
                        self?.database.collection("tweets").document(tweetID).updateData(["likesCount" : FieldValue.increment(Int64(-1))])
                        completion(.success(()))
                    }
                } catch {
                    completion(.failure(FirestoreError.failedToUnlike))
                }
            }
        }
    }
    
    
    func dispatchRetweetRequestFor(tweetID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        database.collection("tweets").document(tweetID).setData(["retweeters":[userId]], merge: true) { [weak self] error in
            if error == nil {
                self?.database.collection("tweets").document(tweetID).updateData(["retweetCount" : FieldValue.increment(Int64(1))])
                completion(.success(()))
            } else {
                completion(.failure(FirestoreError.failedToLike))
            }
        }
    }
    
    func dispatchUnretweetRequestFor(tweetID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        database.collection("tweets").document(tweetID).getDocument { [weak self] result, error in
            if error == nil {
                do {
                    guard let tweet = try result?.data(as: Tweet.self),
                          let retweeterIndex = tweet.retweeters?.firstIndex(of: userId) else {return}
                    var retweeters:[String] = tweet.retweeters!
                    retweeters.remove(at: retweeterIndex)
                    self?.database.collection("tweets").document(tweetID).updateData(["retweeters": retweeters]) { error in
                        self?.database.collection("tweets").document(tweetID).updateData(["retweetCount" : FieldValue.increment(Int64(-1))])
                        completion(.success(()))
                    }
                } catch {
                    completion(.failure(FirestoreError.failedToUnlike))
                }
            }
        }
    }
    
    
    func fetchRepliesForTweetWith(id: String, completion: @escaping (Result<[TweetViewModel], Error>)-> Void) {
        database.collection("tweets").whereField("parentReference", isEqualTo: id).getDocuments { result, error in
            guard let result = result, error == nil else {
                return
            }
            
            var tweets: [Tweet] = [Tweet]()
            do {
                try result.documents.forEach { doc in
                    guard let tweet = try doc.data(as: Tweet.self) else {
                        return
                    }
                    tweets.append(tweet)
                }
            }
            catch {
                completion(.failure(FirestoreError.failedToFetchTweets))
            }
            var tweetViewModels: [TweetViewModel] = [TweetViewModel]()
            for tweet in tweets {
                DatabaseManager.shared.getUserWith(userID: tweet.authorID) { response in
                    switch response {
                    case .success(let user):
                        guard let myAccountId = Auth.auth().currentUser?.uid else {return}
                        tweetViewModels.append(TweetViewModel(id: tweet.id, userID: user.id, displayName: user.displayName, username: user.username, timestamp: tweet.timestamp, tweetTextContent: tweet.tweetTextContent, avatarPath: user.avatarPath, isLiked: (tweet.likers?.contains(myAccountId))!, isRetweeted: (tweet.retweeters?.contains(myAccountId))!))
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    completion(.success(tweetViewModels))
                }
            }
    }
}


}



