//
//  AuthManager.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import Foundation
import FirebaseAuth


enum FireBaseAuthErrors: Error {
    case failedToRegister
    case failedToLogin
}

class AuthManager {
    static let shared = AuthManager()
    
    
    func registerAccountWith(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let _ = result, error == nil else {
                completion(.failure(FireBaseAuthErrors.failedToRegister))
                return
            }
            DatabaseManager.shared.insertUserRecordToDatabaseWith(email: email) { result in
                completion(.success(()))
            }
        }
    }
    
    
    func loginAccountWith(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            guard error == nil else {
                completion(.failure(FireBaseAuthErrors.failedToLogin))
                return
            }
            completion(.success(()))
        }
    }
}
