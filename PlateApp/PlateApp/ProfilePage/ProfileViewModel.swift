//
//  ProfileViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profileSummary: ProfileSummary?
    @Published var posts: [Post] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

    init() {
        loadProfile()
    }

    func loadProfile() {
        guard let user = Auth.auth().currentUser else {
            profileSummary = nil
            posts = []
            return
        }

        isLoading = true

        db.collection("images").addSnapshotListener { [weak self] querySnapshot, error in
            guard let self else { return }

            if let error = error {
                print("Error loading profile posts: \(error)")
                self.posts = []
                self.profileSummary = self.makeProfileSummary(for: user, posts: [])
                self.isLoading = false
                return
            }

            let allPosts = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Post.self)
            } ?? []

            let matchingPosts = allPosts.filter { self.postMatchesCurrentUser($0, user: user) }
            self.posts = matchingPosts
            self.profileSummary = self.makeProfileSummary(for: user, posts: matchingPosts)
            self.isLoading = false
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

    private func makeProfileSummary(for user: User, posts: [Post]) -> ProfileSummary {
        let email = user.email ?? "No email found"
        let defaultDisplayName = email.split(separator: "@").first.map(String.init) ?? "Plate User"
        let displayName = posts.first?.username
        let joinedDate = user.metadata.creationDate.map(Self.dateFormatter.string(from:)) ?? "Recently joined"
        let publicPosts = posts.filter(\.isPublic).count
        let privatePosts = posts.count - publicPosts
        let favoriteSpot = Self.favoriteSpot(from: posts)

        return ProfileSummary(
            displayName: displayName ?? "No Username Found",
            email: email,
            joinedDate: joinedDate,
            totalPosts: posts.count,
            publicPosts: publicPosts,
            privatePosts: privatePosts,
            favoriteSpot: favoriteSpot
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
}
