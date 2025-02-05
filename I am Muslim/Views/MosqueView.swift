import SwiftUI
import MapKit
import CoreLocation

class MosqueViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @Published var mosques: [Mosque] = []
    @Published var selectedMosque: Mosque?
    @Published var isLoading = false
    @Published var showFullMap = false
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private var hasInitialLocation = false
    private let searchRadius: Double = 30000 // 30km radius
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 100 // Update location when user moves 100 meters
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Update region for map
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3) // Wider view for 30km radius
        )
        
        // Search for mosques
        searchNearbyMosques(location: location)
        
        // Only stop updates if we're not showing full map
        if !showFullMap {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
        isLoading = false
    }
    
    func openInMaps(mosque: Mosque) {
        let placemark = MKPlacemark(coordinate: mosque.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = mosque.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    func searchNearbyMosques(location: CLLocation) {
        isLoading = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "mosque"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: searchRadius * 2,
            longitudinalMeters: searchRadius * 2
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Failed to find mosques: \(error.localizedDescription)"
                    self?.mosques = []
                    return
                }
                
                let mappedMosques = response?.mapItems.compactMap { item -> Mosque? in
                    guard let itemLocation = item.placemark.location else { return nil }
                    
                    let address = [item.placemark.thoroughfare, item.placemark.locality]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                    
                    return Mosque(
                        name: item.name ?? "Unknown Mosque",
                        coordinate: item.placemark.coordinate,
                        address: address,
                        distance: location.distance(from: itemLocation)
                    )
                } ?? []
                
                // Sort mosques by distance
                self?.mosques = mappedMosques.sorted { $0.distance < $1.distance }
                
                if self?.mosques.isEmpty == true {
                    self?.errorMessage = "No mosques found nearby"
                }
            }
        }
    }
    
    func refreshMosques() {
        isLoading = true
        errorMessage = nil
        locationManager.startUpdatingLocation()
        
        // If we don't get a location update within 10 seconds, show an error
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            if self?.isLoading == true {
                self?.isLoading = false
                self?.errorMessage = "Unable to get your location. Please check your location settings."
            }
        }
    }
}

struct Mosque: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let distance: CLLocationDistance
    
    var formattedDistance: String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}

struct MosqueView: View {
    @StateObject private var viewModel = MosqueViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background with Islamic Pattern
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
                .onAppear {
                    viewModel.refreshMosques()
                }
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: {
                        if viewModel.showFullMap {
                            viewModel.showFullMap = false
                            viewModel.selectedMosque = nil
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                    .padding(.trailing, 8)
                    
                    Text("Nearby Mosques")
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: { viewModel.refreshMosques() }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .foregroundColor(IslamicTheme.accentColor)
                        }
                        
                        Button(action: { viewModel.showFullMap.toggle() }) {
                            Image(systemName: viewModel.showFullMap ? "list.bullet" : "map.fill")
                                .font(.title2)
                                .foregroundColor(IslamicTheme.accentColor)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                
                if viewModel.showFullMap {
                    // Full Map View
                    ZStack {
                        Map(coordinateRegion: $viewModel.region,
                            showsUserLocation: true,
                            annotationItems: viewModel.mosques) { mosque in
                            MapAnnotation(coordinate: mosque.coordinate) {
                                MosqueMapMarker(mosque: mosque,
                                              isSelected: viewModel.selectedMosque?.id == mosque.id)
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.selectedMosque = mosque
                                        }
                                    }
                            }
                        }
                        .ignoresSafeArea()
                        
                        // Selected Mosque Card
                        if let selectedMosque = viewModel.selectedMosque {
                            VStack {
                                Spacer()
                                MosqueDetailCard(mosque: selectedMosque, viewModel: viewModel)
                                    .padding()
                                    .transition(.opacity)
                            }
                        }
                    }
                } else {
                    // List View with Islamic Pattern Background
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.isLoading {
                                ProgressView("Finding nearby mosques...")
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .foregroundColor(.white)
                                    .padding(.top, 40)
                            } else if let error = viewModel.errorMessage {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.title)
                                        .foregroundColor(.white)
                                    Text(error)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Button(action: { viewModel.refreshMosques() }) {
                                        Text("Try Again")
                                            .foregroundColor(IslamicTheme.accentColor)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.top, 40)
                            } else if viewModel.mosques.isEmpty {
                                Text("No mosques found nearby")
                                    .foregroundColor(.white)
                                    .padding(.top, 40)
                            } else {
                                ForEach(viewModel.mosques) { mosque in
                                    MosqueListItem(mosque: mosque)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// Add a scale animation when tapping the mosque card
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeIn(duration: 0.2), value: configuration.isPressed)
    }
}

struct MosqueMapMarker: View {
    let mosque: Mosque
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 20))
                .foregroundColor(isSelected ? IslamicTheme.accentColor : .white)
                .padding(8)
                .background(
                    Circle()
                        .fill(isSelected ? .white : IslamicTheme.accentColor)
                        .shadow(radius: 2)
                )
            
            if isSelected {
                Text(mosque.name)
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .shadow(radius: 2)
                    )
            }
        }
    }
}

struct MosqueListItem: View {
    let mosque: Mosque
    @State private var showingDirections = false
    
    var body: some View {
        Button(action: { showingDirections = true }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "building.columns.fill")
                        .font(.title3)
                        .foregroundColor(IslamicTheme.accentColor)
                    
                    Text(mosque.name)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.white)
                }
                
                if !mosque.address.isEmpty {
                    Text(mosque.address)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(IslamicTheme.accentColor)
                    Text(String(format: "%.1f km", mosque.distance / 1000))
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    // Directions hint
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .foregroundColor(IslamicTheme.accentColor)
                        Text("Get Directions")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .confirmationDialog("Open in Maps", isPresented: $showingDirections) {
            Button("Get Directions") {
                openInMaps(mode: .directions)
            }
            Button("View on Map") {
                openInMaps(mode: .view)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose how you would like to view \(mosque.name)")
        }
    }
    
    private func openInMaps(mode: MapMode) {
        let placemark = MKPlacemark(coordinate: mosque.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = mosque.name
        
        switch mode {
        case .directions:
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        case .view:
            mapItem.openInMaps(launchOptions: nil)
        }
    }
    
    private enum MapMode {
        case directions
        case view
    }
}

struct MosqueDetailCard: View {
    let mosque: Mosque
    let viewModel: MosqueViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.title2)
                    .foregroundColor(IslamicTheme.accentColor)
                
                Text(mosque.name)
                    .font(.system(.title3, design: .serif))
                    .foregroundColor(.white)
            }
            
            if !mosque.address.isEmpty {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(IslamicTheme.accentColor)
                    Text(mosque.address)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(IslamicTheme.accentColor)
                Text(String(format: "%.1f km", mosque.distance / 1000))
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Button(action: { viewModel.openInMaps(mosque: mosque) }) {
                HStack {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                    Text("Get Directions")
                        .font(.system(.subheadline, design: .serif))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(IslamicTheme.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.bottom, 20)
    }
}
