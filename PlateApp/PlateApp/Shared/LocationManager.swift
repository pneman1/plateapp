//
//  LocationManager.swift
//  PlateApp
//
//  Created by Ryan Windle on 4/7/26.
//

import CoreLocation

import Foundation
import FirebaseFirestore
import Firebase

public class LocationHelper {
    public static let shared = LocationHelper()

    public func getCityName(from location: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let localGeocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second buffer
            localGeocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
                if let error = error {
                    print("Location Error: \(error.localizedDescription)")
                    completion("Unknown Location")
                    return
                }
                if let placemark = placemarks?.first {
                    let city = placemark.locality ?? "Unknown City"
                    let state = placemark.administrativeArea ?? ""
                    completion("\(city), \(state)")
                }
            }
        }
    }
}
