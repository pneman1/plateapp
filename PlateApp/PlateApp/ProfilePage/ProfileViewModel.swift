//
//  ProfileViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profileSummary: ProfileSummary?
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var isShowingImagePicker = false
    @Published var selectedImage: UIImage? = nil
    @Published var isUploadingImage = false
    @Published var uploadErrorMessage: String? = nil

    private let db = Firestore.firestore()
    private var imagesListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    private var currentProfileImageURL: String? = nil

    init() {
        loadProfile()
        observeUserDocument()
    }

    func loadProfile() {
        guard let user = Auth.auth().currentUser else {
            profileSummary = nil
            posts = []
            return
        }

        isLoading = true

        imagesListener?.remove()
        imagesListener = db.collection("images")
            .whereField("userID", isEqualTo: user.uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error loading profile posts: \(error)")
                    self.posts = []
                    self.profileSummary = self.makeProfileSummary(for: user, posts: [], profileImageURL: self.currentProfileImageURL)
                    self.isLoading = false
                    return
                }

                let matchingPosts = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Post.self)
                } ?? []

                self.posts = matchingPosts
                self.profileSummary = self.makeProfileSummary(for: user, posts: matchingPosts, profileImageURL: self.currentProfileImageURL)
                self.isLoading = false
            }
    }

    private func observeUserDocument() {
        guard let user = Auth.auth().currentUser else { return }
        userListener?.remove()

        userListener = db.collection("users").document(user.uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error listening to user doc: \(error)")
                return
            }

            if let snapshot = snapshot, snapshot.exists {
                if let data = snapshot.data() {
                    self.currentProfileImageURL = data["profileImageURL"] as? String
                }

                if let firebaseUser = Auth.auth().currentUser {
                    self.profileSummary = self.makeProfileSummary(for: firebaseUser, posts: self.posts, profileImageURL: self.currentProfileImageURL)
                }
            }
        }
    }

    private func postMatchesCurrentUser(_ post: Post, user: User) -> Bool {
        let normalizedUserID = normalize(post.userID)
        let candidates = [
            user.uid,
            user.email,
            user.email?.split(separator: "@").first.map(String.init)
        ]
        .compactMap { $0 }
        .map(normalize)

        return candidates.contains(normalizedUserID)
    }

    private func makeProfileSummary(for user: User, posts: [Post], profileImageURL: String? = nil) -> ProfileSummary {
        let email = user.email ?? "No email found"
        let defaultDisplayName = email.split(separator: "@").first.map(String.init) ?? "Plate User"
        let displayName = posts.first?.userID.isEmpty == false ? posts.first?.userID ?? defaultDisplayName : defaultDisplayName
        let joinedDate = user.metadata.creationDate.map(Self.dateFormatter.string(from:)) ?? "Recently joined"
        let publicPosts = posts.filter(\.isPublic).count
        let privatePosts = posts.count - publicPosts
        let favoriteSpot = Self.favoriteSpot(from: posts)

        return ProfileSummary(
            displayName: displayName,
            email: email,
            joinedDate: joinedDate,
            totalPosts: posts.count,
            publicPosts: publicPosts,
            privatePosts: privatePosts,
            favoriteSpot: favoriteSpot,
            profileImageURL: profileImageURL
        )
    }

    private func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static func favoriteSpot(from posts: [Post]) -> String {
        let counts = posts.reduce(into: [String: Int]()) { partialResult, post in
            let key = post.locationString.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { return }
            partialResult[key, default: 0] += 1
        }

        return counts.max { $0.value < $1.value }?.key ?? "No posts yet"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    deinit {
        imagesListener?.remove()
        userListener?.remove()
    }

    // MARK: - Profile Image Upload
    func uploadProfileImage(image: UIImage) {
        guard let user = Auth.auth().currentUser else { return }
        isUploadingImage = true

        StorageManager.shared.uploadProfileImage(image: image, forUserUID: user.uid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isUploadingImage = false

                switch result {
                case .success(let url):
                    let urlString = url.absoluteString
                    self.db.collection("users").document(user.uid).setData(["profileImageURL": urlString], merge: true) { error in
                        if let error = error {
                            print("Failed to set user profile image URL: \(error)")
                            self.uploadErrorMessage = "Failed to save profile image."
                        } else {
                            // Update local state immediately
                            self.currentProfileImageURL = urlString
                            if let firebaseUser = Auth.auth().currentUser {
                                self.profileSummary = self.makeProfileSummary(for: firebaseUser, posts: self.posts, profileImageURL: self.currentProfileImageURL)
                            }
                            self.selectedImage = nil
                            self.uploadErrorMessage = nil
                            print("Profile image URL updated")
                        }
                    }

                case .failure(let error):
                    print("Profile image upload error: \(error)")
                    self.uploadErrorMessage = error.localizedDescription
                }
            }
        }
    }
}
