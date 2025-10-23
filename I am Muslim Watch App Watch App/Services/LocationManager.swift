//
//  LocationManager.swift
//  I am Muslim Watch App Watch App
//
//  Created by Cascade AI on 25/04/2025.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var locationName: String = "Loading location..."
    @Published var authorizationStatus: CLAuthorizationStatus
    
    var onLocationNameUpdate: ((String) -> Void)?
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // Update every 1km
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationName = "Location access denied"
        case .notDetermined:
            locationName = "Location not determined"
        @unknown default:
            locationName = "Unknown location status"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Only update if significant change or first update
        if self.location == nil || self.location!.distance(from: location) > 1000 {
            self.location = location
            updateLocationName(for: location)
            
            // Notify about location update
            onLocationUpdate?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        locationName = "Location error"
    }
    
    private func updateLocationName(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                self.locationName = "Unknown location"
                return
            }
            
            if let placemark = placemarks?.first {
                let name = [placemark.locality, placemark.administrativeArea, placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                
                if !name.isEmpty {
                    self.locationName = name
                    self.onLocationNameUpdate?(name)
                } else {
                    self.locationName = "Unknown location"
                }
            } else {
                self.locationName = "Unknown location"
            }
        }
    }
}
