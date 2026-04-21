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
}
