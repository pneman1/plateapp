//
//  StorageManager.swift
//  PlateApp
//
//  Created by Ryan Windle on 4/16/26.
//
import FirebaseStorage
import UIKit

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    func uploadPostImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        // 1. Convert UIImage to Data (compression saves data/bandwidth)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "ImageConversion", code: 0)))
            return
        }
        
        // 2. Create a unique filename
        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.child("post_images/\(filename)")
        
        // 3. Upload the data
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 4. Get the download URL
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }
    }

    /// Uploads a profile image and returns the public download URL.
    /// If a user UID is provided the file will be written as `profile_<uid>.jpg` so it overwrites previous profile images for that user.
    func uploadProfileImage(image: UIImage, forUserUID uid: String? = nil, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            completion(.failure(NSError(domain: "ImageConversion", code: 0)))
            return
        }

        let filename: String
        if let uid = uid, !uid.isEmpty {
            filename = "profile_\(uid).jpg"
        } else {
            filename = "profile_\(UUID().uuidString).jpg"
        }

        let ref = storage.child("profile_images/\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let _ = ref.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }
    }
}
