//
//  FeedModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//
import Foundation
import FirebaseFirestore
import Firebase

struct GeoPoint: Codable {
    let latitude: Double
    let longitude: Double
    
    
}

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    let userID: String
    let imageURL: String
    let caption: String
    let timestamp: String
    let location: String
    let isPublic: Bool
}

struct PlateLocation: Codable {
    let geopoint: GeoPoint
    let geohash: String
    let restaurantName: String
}
