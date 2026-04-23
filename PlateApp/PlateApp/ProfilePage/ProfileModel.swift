//
//  ProfileModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import Foundation
import Firebase
import FirebaseFirestore

struct ProfileSummary {
    let displayName: String
    let email: String
    let joinedDate: String
    let totalPosts: Int
    let publicPosts: Int
    let privatePosts: Int
    let favoriteSpot: String
    let profileImageURL: String?
}

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var username: String
    var profileImageURL: String
    var email: String
}

struct FriendRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var userIDs: [String]
    var senderID: String
    var status: String
    var recipientID: String
    var timestamp: Date
}
