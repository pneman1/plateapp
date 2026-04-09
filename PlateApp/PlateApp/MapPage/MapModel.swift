//
//  MapModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import CoreLocation
import Foundation

struct MapHotspot: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let postCount: Int
}
