//
//  FeedViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import SwiftUI
import FirebaseFirestore
import Foundation
import FirebaseAuth


@MainActor
class FeedViewModel: ObservableObject{
    @Published var posts: [Post] = []
    @Published var userProfileURLs: [String: URL] = [:] // userID -> profileImageURL (absence / missing key means none)
    
    private var db = Firestore.firestore()
    private var postsListener: ListenerRegistration?
    
    init() {
        Task {
            await fetchPosts()
        }
    }

    func fetchPosts() async {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        do {
            let friendshipSnapshot = try await db.collection("friendships")
                .whereField("userIDs", arrayContains: uid)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            
            // 2. Map the documents to get the "other" person's ID
            var friendIDs = friendshipSnapshot.documents.compactMap { doc -> String? in
                guard let ids = doc.data()["userIDs"] as? [String] else { return nil }
                // Filter out the current user, leaving only the friend's ID
                return ids.first { $0 != uid }
            }
            
            friendIDs.append(uid)
            
            let finalIDs = Array(friendIDs.prefix(30))
            
            guard !finalIDs.isEmpty else {
                print("no friends")
                return
            }
        
            
            // 6. Set up the Real-time listener for posts
            // Remove any existing listener to avoid duplicate callbacks
            postsListener?.remove()
            postsListener = db.collection("images")
                .whereField("userID", in: finalIDs)
                .order(by: "timestamp", descending: true)
                .addSnapshotListener { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching feed: \(error.localizedDescription)")
                        return
                    }

                    // Decode the posts into your local published array
                    self.posts = querySnapshot?.documents.compactMap { doc in
                        try? doc.data(as: Post.self)
                    } ?? []

                    // Resolve profile image URLs for the authors in these posts (batched)
                    self.resolveProfileImageURLs(for: self.posts)

                    print(self.posts)
                }
        } catch {
            print("error fetching feed")
        }
    }

    deinit {
        postsListener?.remove()
    }

    /// Refresh posts and profile image cache when the user triggers pull-to-refresh.
    @MainActor
    func refresh() async {
        // Clear cached profile URLs so we fetch fresh values
        userProfileURLs.removeAll()

        // Do a one-off fetch of posts (avoid depending on the listener's timing)
        await oneOffFetchPosts()
    }

    /// One-off posts fetch used by pull-to-refresh so we can immediately refresh the avatar cache.
    @MainActor
    private func oneOffFetchPosts() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let friendshipSnapshot = try await db.collection("friendships")
                .whereField("userIDs", arrayContains: uid)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()

            var friendIDs = friendshipSnapshot.documents.compactMap { doc -> String? in
                guard let ids = doc.data()["userIDs"] as? [String] else { return nil }
                return ids.first { $0 != uid }
            }

            friendIDs.append(uid)
            let finalIDs = Array(friendIDs.prefix(30))
            guard !finalIDs.isEmpty else { return }

            let snapshot = try await db.collection("images")
                .whereField("userID", in: finalIDs)
                .order(by: "timestamp", descending: true)
                .getDocuments()

            let newPosts = snapshot.documents.compactMap { doc in
                try? doc.data(as: Post.self)
            }

            self.posts = newPosts

            // Immediately resolve profile image URLs for these posts
            self.resolveProfileImageURLs(for: self.posts)
        } catch {
            print("oneOffFetchPosts error: \(error)")
        }
    }

    // MARK: - Profile image resolution
    /// Fetch profileImageURL entries for all users present in the posts (batched by userID).
    private func resolveProfileImageURLs(for posts: [Post]) {
        // Collect unique userIDs that we don't yet have cached
        let missingUserIDs = Array(Set(posts.compactMap { $0.userID }).filter { userID in
            return self.userProfileURLs[userID] == nil
        })

        print("resolveProfileImageURLs: missingUserIDs=\(missingUserIDs)")

        guard !missingUserIDs.isEmpty else { return }

        // Firestore 'in' queries accept up to 10 elements. Split into chunks.
        let batchSize = 10
        let batches = stride(from: 0, to: missingUserIDs.count, by: batchSize).map { start -> [String] in
            let end = Swift.min(start + batchSize, missingUserIDs.count)
            return Array(missingUserIDs[start..<end])
        }

        for batch in batches {
            print("resolveProfileImageURLs: querying batch=\(batch)")
            // Remove any previous listener for safety (we're doing one-off reads)
            db.collection("users")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching user profiles for avatars (batch): \(error.localizedDescription). Falling back to per-user fetch for batch: \(batch)")
                        // Fallback: try per-user getDocument for each id
                        for uid in batch {
                            self.fetchProfileURLForUser(uid: uid)
                        }
                        return
                    }

                    let returnedDocs = snapshot?.documents ?? []
                    let returnedIDs: [String] = returnedDocs.map { $0.documentID }

                    print("resolveProfileImageURLs: batch returnedIDs=\(returnedIDs)")

                    // Update cache for returned docs
                    for doc in returnedDocs {
                        let uid = doc.documentID
                        let data = doc.data()
                        let urlString = data["profileImageURL"] as? String ?? ""
                        if urlString.isEmpty {
                            print("resolveProfileImageURLs: received empty profileImageURL for uid=\(uid) — removing from cache")
                            DispatchQueue.main.async {
                                self.userProfileURLs.removeValue(forKey: uid)
                            }
                        } else if let url = URL(string: urlString) {
                            print("resolveProfileImageURLs: caching uid=\(uid) url=\(urlString)")
                            DispatchQueue.main.async {
                                self.userProfileURLs[uid] = url
                            }
                        } else {
                            print("resolveProfileImageURLs: invalid URL string for uid=\(uid): \(urlString) — removing from cache")
                            DispatchQueue.main.async {
                                self.userProfileURLs.removeValue(forKey: uid)
                            }
                        }
                    }

                    // For any IDs in this batch that weren't returned (missing user doc), fallback to per-user fetch
                    let missingFromThisBatch = batch.filter { !returnedIDs.contains($0) }
                    if !missingFromThisBatch.isEmpty {
                        for missingID in missingFromThisBatch {
                            print("resolveProfileImageURLs: missing doc for id=\(missingID), falling back")
                            self.fetchProfileURLForUser(uid: missingID)
                        }
                    }
                }
        }
    }

    /// Helper fallback: fetch a single user doc and cache its profileImageURL (or empty string). Logs errors.
    private func fetchProfileURLForUser(uid: String) {
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user doc for avatar fallback (\(uid)): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // If we can't fetch the user doc, ensure we don't leave a stale/empty entry in the cache
                    self.userProfileURLs.removeValue(forKey: uid)
                }
                return
            }

            guard let data = snapshot?.data() else {
                print("User doc missing for avatar fallback: \(uid)")
                DispatchQueue.main.async {
                    self.userProfileURLs.removeValue(forKey: uid)
                }
                return
            }

            let urlString = data["profileImageURL"] as? String ?? ""
            if urlString.isEmpty {
                print("fetchProfileURLForUser: uid=\(uid) url is empty — removing from cache")
                DispatchQueue.main.async {
                    self.userProfileURLs.removeValue(forKey: uid)
                }
            } else if let url = URL(string: urlString) {
                print("fetchProfileURLForUser: uid=\(uid) url=\(urlString)")
                DispatchQueue.main.async {
                    self.userProfileURLs[uid] = url
                }
            } else {
                print("fetchProfileURLForUser: uid=\(uid) invalid URL string=\(urlString) — removing from cache")
                DispatchQueue.main.async {
                    self.userProfileURLs.removeValue(forKey: uid)
                }
            }
        }
    }
    
    func deletePost(postID: String?, authVM: AuthViewModel) async {
        guard let id = postID else {
            print("Error: Post ID is nil, cannot delete.")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        do {
            try await db.collection("images").document(id).delete()
            print("Document successfully removed!")
            
            // Fetch the user's most recent remaining post
            let snapshot = try await db.collection("images")
                .whereField("userID", isEqualTo: uid)
                .order(by: "timestamp", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            if let document = snapshot.documents.first {
                let latestPost = try document.data(as: Post.self)
                await authVM.updateLastPostDate(date: latestPost.timestamp)
            } else {
                await authVM.updateLastPostDate(date: nil)
            }
            
            await fetchPosts()
        } catch {
            print("Error deleting document or updating status: \(error.localizedDescription)")
        }
    }
}
