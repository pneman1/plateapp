//
//  MapViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import CoreLocation
import FirebaseFirestore
import Foundation

@MainActor
final class MapViewModel: ObservableObject {
    @Published var clusters: [MapPhotoCluster] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchClusters()
    }

    deinit {
        listener?.remove()
    }

    private func fetchClusters() {
        listener?.remove()
        listener = db.collection("images").addSnapshotListener { [weak self] querySnapshot, error in
            guard let self else { return }

            if let error = error {
                print("Error getting map documents: \(error)")
                return
            }

            let posts = querySnapshot?.documents.compactMap { document -> Post? in
                try? document.data(as: Post.self)
            } ?? []

            let visiblePosts = posts
                .filter { $0.homeCooked != true }
                .sorted { $0.timestamp > $1.timestamp }

            self.clusters = Self.cluster(visiblePosts)
        }
    }

    private static func cluster(_ posts: [Post]) -> [MapPhotoCluster] {
        let gridSize = 0.008
        var buckets: [String: [Post]] = [:]

        for post in posts {
            let coordinate = CLLocationCoordinate2D(
                latitude: post.location.geopoint.latitude,
                longitude: post.location.geopoint.longitude
            )

            let latBucket = (coordinate.latitude / gridSize).rounded() * gridSize
            let lonBucket = (coordinate.longitude / gridSize).rounded() * gridSize
            let key = "\(latBucket),\(lonBucket)"
            buckets[key, default: []].append(post)
        }

        return buckets.map { key, bucketPosts in
            let latitude = bucketPosts
                .map { $0.location.geopoint.latitude }
                .reduce(0, +) / Double(bucketPosts.count)
            let longitude = bucketPosts
                .map { $0.location.geopoint.longitude }
                .reduce(0, +) / Double(bucketPosts.count)

            return MapPhotoCluster(
                id: key,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                posts: bucketPosts.sorted { $0.timestamp > $1.timestamp }
            )
        }
        .sorted { lhs, rhs in
            let lhsDate = lhs.coverPost?.timestamp ?? .distantPast
            let rhsDate = rhs.coverPost?.timestamp ?? .distantPast
            return lhsDate > rhsDate
        }
    }
}
