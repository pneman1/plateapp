//
//  MapViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import CoreLocation
import FirebaseFirestore
import Foundation

class MapViewModel: ObservableObject {
    @Published var hotspots: [MapHotspot] = []

    private let db = Firestore.firestore()

    init() {
        fetchHotspots()
    }

    private func fetchHotspots() {
        db.collection("images").addSnapshotListener { [weak self] querySnapshot, error in
            guard let self else { return }

            if let error = error {
                print("Error getting map documents: \(error)")
                return
            }

            let coordinates = querySnapshot?.documents.compactMap { document in
                Self.coordinate(from: document.data())
            } ?? []

            let hotspots = Self.cluster(coordinates)

            DispatchQueue.main.async {
                self.hotspots = hotspots
            }
        }
    }

    private static func coordinate(from data: [String: Any]) -> CLLocationCoordinate2D? {
        if let location = data["location"] as? [String: Any] {
            if let geopoint = location["geopoint"] as? FirebaseFirestore.GeoPoint {
                return CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
            }

            if let latitude = location["latitude"] as? Double,
               let longitude = location["longitude"] as? Double {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }

        if let geopoint = data["geopoint"] as? FirebaseFirestore.GeoPoint {
            return CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
        }

        if let latitude = data["latitude"] as? Double,
           let longitude = data["longitude"] as? Double {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        return nil
    }

    private static func cluster(_ coordinates: [CLLocationCoordinate2D]) -> [MapHotspot] {
        let gridSize = 0.01
        var buckets: [String: [CLLocationCoordinate2D]] = [:]

        for coordinate in coordinates {
            let latBucket = (coordinate.latitude / gridSize).rounded() * gridSize
            let lonBucket = (coordinate.longitude / gridSize).rounded() * gridSize
            let key = "\(latBucket),\(lonBucket)"
            buckets[key, default: []].append(coordinate)
        }

        return buckets.map { key, coordinates in
            let latitude = coordinates.map(\.latitude).reduce(0, +) / Double(coordinates.count)
            let longitude = coordinates.map(\.longitude).reduce(0, +) / Double(coordinates.count)

            return MapHotspot(
                id: key,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                postCount: coordinates.count
            )
        }
    }
}
