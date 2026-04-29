//
//  MapModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import CoreLocation
import Foundation

struct MapPhotoCluster: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let posts: [Post]

    var postCount: Int {
        posts.count
    }

    var coverPost: Post? {
        posts.first
    }

    var title: String {
        coverPost?.location.restaurantName ?? "Plate!"
    }
}
