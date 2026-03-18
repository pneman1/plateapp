//
//  FeedModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//
import Foundation

struct GeoPoint: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct Post: Identifiable, Codable {
    var id: String { postID }
    let postID: String
    let authorID: String
    let imageURL: String
    let caption: String
    let timestamp: Date
    let location: PlateLocation
    let isPublic: Bool
}

struct PlateLocation: Codable {
    let geopoint: GeoPoint
    let geohash: String
    let restaurantName: String
}
