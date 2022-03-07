//
//  FirestoreManager.swift
//  TwitterProject
//
//  Created by Amr Hossam on 18/02/2022.
//

import FirebaseStorage
import UIKit

class FirestoreManager {
    
    enum FirestoreError: Error {
        case failedToUploadImage
    }
    
    static let shared = FirestoreManager()
    private let bucket = Storage.storage().reference()

    
    
    func uploadUserImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let name = UUID.init().uuidString
        let uploadRef = bucket.child("images").child("\(name).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.15) else {return}
        let uploadMetaData = StorageMetadata.init()
        uploadMetaData.contentType = "image/jpeg"
        let taskRef = uploadRef.putData(imageData, metadata: uploadMetaData) { downloadMetaData, error in
            if error != nil {
                print("Error: upload")
                completion(.failure(FirestoreError.failedToUploadImage))
            }
            uploadRef.downloadURL { url, error in
                guard let url = url else {return}
                completion(.success(url))
            }            
        }
        taskRef.observe(.progress) { snapShot in
            guard let currentPr = snapShot.progress?.fractionCompleted else {
                return
            }
            
            print(currentPr)
            
        }
    }
    
    
    
}
