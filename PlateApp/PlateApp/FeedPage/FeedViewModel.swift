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
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                }
                
                self.posts = querySnapshot?.documents.compactMap {doc in
                    try? doc.data(as: Post.self)
                } ?? []
                
                print(self.posts)
            }
        
    }
}
