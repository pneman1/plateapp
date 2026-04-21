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

public class LocationHelper: NSObject, CLLocationManagerDelegate {
    public static let shared = LocationHelper()
    
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationCompletion: ((CLLocation) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    public func requestLocation(completion: @escaping (CLLocation) -> Void) {
        self.locationCompletion = completion
        
        manager.requestWhenInUseAuthorization()
        
        manager.requestLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationCompletion?(location)
            locationCompletion = nil // Reset after one use
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }

    // Your existing city name function remains here
    public func getCityName(from location: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let localGeocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        localGeocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? "Unknown City"
                let state = placemark.administrativeArea ?? ""
                completion("\(city), \(state)")
            }
        }
    }
}
