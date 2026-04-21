//
//  FeedViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import SwiftUI
import FirebaseFirestore
import Foundation


@MainActor
class FeedViewModel: ObservableObject{
    @Published var posts: [Post] = []
    
    private var db = Firestore.firestore()
    
    init () {
        fetchPosts()
    }

    func fetchPosts(){
        db.collection("images")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                
                self.posts = querySnapshot?.documents.compactMap { doc in
                    do {
                        // This is the "Gold Standard" way to decode Firestore documents
                        return try doc.data(as: Post.self)
                    } catch {
                        print("Decoding Error for \(doc.documentID): \(error)")
                        // This print will tell you exactly which field (e.g. "userID") is missing or wrong
                        return nil
                    }
                } ?? []
                
                print(self.posts)
            }
        
    }
    
    func uploadMockPost() {
        let newPost = Post(
            userID: "upload_test",
            imageURL: "https://i.imgur.com/RpzNeWO.jpeg",
            caption: "Hello from Seattle!",
            timestamp: Date(),
            location: PlateLocation(
                geopoint: GeoPoint(latitude: 47.71466349381602, longitude: -122.36316745682254),
                restaurantName: "SEATTLE"
            ),
            rating: 5,
            mealType: "Lunch",
            isPublic: true
        )
        
        let collectionRef = db.collection("images")
        
        do {
            try collectionRef.addDocument(from: newPost)
            print("✅ Success: Mock post uploaded to Firestore!")
        } catch {
            print("❌ Error uploading post: \(error.localizedDescription)")
        }
    }
    
    func deletePost(postID: String?) {
        guard let id = postID else {
            print("Error: Post ID is nil, cannot delete.")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("images").document(id).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
