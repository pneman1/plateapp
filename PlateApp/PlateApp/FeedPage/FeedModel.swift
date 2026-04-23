//
//  FeedModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//
import Foundation
import FirebaseFirestore
import Firebase

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let userID: String
    let username: String
    let imageURL: String
    let caption: String
    let timestamp: Date
    let location: PlateLocation
    let rating: Int
    let mealType: String
    let isPublic: Bool
}

struct PlateLocation: Codable {
    let geopoint: GeoPoint
    let restaurantName: String
}

//struct GeoPoint: Codable {
//    let latitude: Double
//    let longitude: Double
//}


extension Post {
    var dateString: String {
        timestamp.formatted(date: .abbreviated, time: .omitted)
    }
    
    var locationString: String {
        "\(location.restaurantName)"
    }
}
