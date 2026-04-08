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
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func fetchPosts(){
        db.collection("images")
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
            caption: "Hello from Washington!",
            timestamp: Date(),
            location: PlateLocation(
                geopoint: GeoPoint(latitude: 38.90364464314628, longitude: -77.03904851767572),
                geohash: "dr4e",
                restaurantName: "Restaurant in Washington, D.C."
            ),
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
}
