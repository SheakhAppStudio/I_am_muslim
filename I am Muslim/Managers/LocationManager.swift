import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var locationName: String = "Loading location..."
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var isUsingCustomLocation = false
    
    private let minimumUpdateInterval: TimeInterval = 300 // 5 minutes
    private let significantDistanceThreshold: CLLocationDistance = 1000 // 1 kilometer
    private var lastSignificantUpdate: Date?
    
    var onLocationNameUpdate: ((String) -> Void)?
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // Request authorization immediately if not determined
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Start updating location if we don't have one and user has authorized
        if location == nil {
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                startUpdatingLocation()
            }
        }
    }
    
    func startUpdatingLocation() {
        // Request a single location update
        locationManager.requestLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func setCustomLocation(coordinate: CLLocationCoordinate2D, name: String) {
        stopUpdatingLocation()
        isUsingCustomLocation = true
        location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        locationName = name
        onLocationNameUpdate?(name)
    }
    
    func useCurrentLocation() {
        isUsingCustomLocation = false
        location = nil // Reset location to force an update
        lastSignificantUpdate = nil // Reset last update time
        locationName = "Loading location..." // Reset location name
        onLocationNameUpdate?("Loading location...")
        startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
              !isUsingCustomLocation else {
            return
        }
        
        DispatchQueue.main.async {
            self.location = newLocation
            self.lastSignificantUpdate = Date()
            self.updateLocationName(for: newLocation)
            NotificationCenter.default.post(name: .init("LocationDidUpdate"), object: nil)
            
            // Stop updating immediately after getting location
            self.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // Only start updating if we don't have a location yet
                if self.location == nil {
                    self.startUpdatingLocation()
                }
            case .denied, .restricted:
                self.stopUpdatingLocation()
                self.location = nil
                self.locationName = "Location access denied"
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func shouldUpdateLocation(_ newLocation: CLLocation) -> Bool {
        // Since we only update when requested, we accept any valid location
        return true
    }
    
    private func updateLocationName(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else {
                return
            }
            
            let name = [placemark.locality, placemark.administrativeArea]
                .compactMap { $0 }
                .joined(separator: ", ")
            
            DispatchQueue.main.async {
                self.locationName = name.isEmpty ? "Unknown Location" : name
                self.onLocationNameUpdate?(self.locationName)
            }
        }
    }
}
