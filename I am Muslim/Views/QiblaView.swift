import SwiftUI
import CoreLocation

class QiblaViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double = 0
    @Published var qiblaDirection: Double = 0
    @Published var locationStatus: LocationStatus = .unknown
    @Published var distance: Double = 0
    @Published var directionStatus: DirectionStatus = .searching
    
    private let locationManager = CLLocationManager()
    private let directionThreshold: Double = 5 // Degrees of tolerance
    
    enum LocationStatus {
        case unknown
        case noPermission
        case locating
        case located
        
        var message: String {
            switch self {
            case .unknown:
                return "Initializing compass..."
            case .noPermission:
                return "Please enable location services to find Qibla direction"
            case .locating:
                return "Finding your location..."
            case .located:
                return "Follow the arrow to find Qibla"
            }
        }
    }
    
    enum DirectionStatus {
        case searching
        case close
        case found
        case wrong
        
        var message: String {
            switch self {
            case .searching:
                return "Searching for Qibla direction..."
            case .close:
                return "Getting closer! Keep rotating..."
            case .found:
                return "Alhamdulillah! You're facing Qibla"
            case .wrong:
                return "Keep rotating..."
            }
        }
        
        var color: Color {
            switch self {
            case .searching:
                return .white
            case .close:
                return .yellow
            case .found:
                return .green
            case .wrong:
                return .white.opacity(0.7)
            }
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading
        updateQiblaDirection()
        updateDirectionStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateQiblaDirection(from: location)
        locationStatus = .located
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatus = .locating
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationStatus = .noPermission
        default:
            locationStatus = .unknown
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            locationStatus = .noPermission
        }
    }
    
    private func updateQiblaDirection(from location: CLLocation? = nil) {
        // Kaaba coordinates
        let kaabaLat = 21.4225
        let kaabaLng = 39.8262
        
        guard let currentLocation = location ?? locationManager.location else { return }
        let currentLat = currentLocation.coordinate.latitude
        let currentLng = currentLocation.coordinate.longitude
        
        // Calculate distance to Kaaba
        let kaabaLocation = CLLocation(latitude: kaabaLat, longitude: kaabaLng)
        distance = currentLocation.distance(from: kaabaLocation) / 1000 // Convert to kilometers
        
        // Calculate Qibla direction
        let latRad = currentLat * .pi / 180
        let longRad = currentLng * .pi / 180
        let kaabaLatRad = kaabaLat * .pi / 180
        let kaabaLongRad = kaabaLng * .pi / 180
        
        let y = sin(kaabaLongRad - longRad)
        let x = cos(latRad) * tan(kaabaLatRad) - sin(latRad) * cos(kaabaLongRad - longRad)
        var qiblaAngle = atan2(y, x)
        
        qiblaAngle = qiblaAngle * 180 / .pi
        if qiblaAngle < 0 {
            qiblaAngle += 360
        }
        
        qiblaDirection = qiblaAngle
    }
    
    private func updateDirectionStatus() {
        let currentDirection = heading
        let targetDirection = qiblaDirection
        
        // Calculate the absolute difference between current and target direction
        var difference = abs(currentDirection - targetDirection)
        difference = min(difference, 360 - difference) // Handle wrap-around
        
        // Update direction status based on how close we are to the target
        if difference <= directionThreshold {
            directionStatus = .found
        } else if difference <= 20 {
            directionStatus = .close
        } else {
            directionStatus = .wrong
        }
    }
    
    func recalibrate() {
        locationManager.stopUpdatingHeading()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
}

struct QiblaView: View {
    @StateObject private var viewModel = QiblaViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingHelp = false
    @State private var compassScale: CGFloat = 1.0
    @State private var isCalibrating = false
    
    var body: some View {
        ZStack {
            // Background with Islamic Pattern
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                    .padding(.trailing, 8)
                    
                    Text("Qibla Finder")
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingHelp = true }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                
                Spacer()
                    .frame(height: 20)
                
                // Compass Container
                ZStack {
                    // Outer Circle
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 280, height: 280)
                    
                    // Inner Circle
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        .frame(width: 220, height: 220)
                    
                    // Compass Rose
                    ForEach(0..<8) { index in
                        let angle = Double(index) * 45.0
                        let text = compassDirection(for: angle)
                        Text(text)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .rotationEffect(.degrees(-viewModel.heading))
                            .offset(y: -120)
                            .rotationEffect(.degrees(angle))
                    }
                    
                    // Compass Image
                    Image("compass_bg")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-viewModel.heading))
                        .scaleEffect(compassScale)
                    
                    // Qibla Arrow
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 40))
                        .foregroundColor(viewModel.directionStatus.color)
                        .rotationEffect(.degrees(viewModel.qiblaDirection - viewModel.heading))
                        .shadow(color: viewModel.directionStatus.color.opacity(0.5), radius: 10)
                }
                .overlay(
                    Circle()
                        .stroke(viewModel.directionStatus.color.opacity(0.3), lineWidth: 3)
                        .frame(width: 280, height: 280)
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.heading)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.qiblaDirection)
                
                Spacer()
                
                // Status and Controls
                VStack(spacing: 16) {
                    if viewModel.locationStatus == .located {
                        Text(viewModel.directionStatus.message)
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(viewModel.directionStatus.color)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .animation(.easeInOut, value: viewModel.directionStatus)
                        
                        if viewModel.distance > 0 {
                            Text(String(format: "%.0f km from Kaaba", viewModel.distance))
                                .font(.system(.subheadline, design: .serif))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else {
                        Text(viewModel.locationStatus.message)
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Calibration Button
                    Button(action: {
                        withAnimation {
                            isCalibrating = true
                            compassScale = 0.8
                        }
                        
                        // Simulate calibration
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isCalibrating = false
                                compassScale = 1.0
                            }
                        }
                        
                        viewModel.recalibrate()
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Calibrate Compass")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                    }
                    .opacity(viewModel.locationStatus == .located ? 1 : 0)
                }
                .padding(.bottom, 30)
            }
            
            // Calibration Overlay
            if isCalibrating {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            Image(systemName: "figure.8")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(isCalibrating ? 360 : 0))
                                .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: isCalibrating)
                            
                            Text("Move your phone in a figure 8 pattern")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                                .padding(.top)
                        }
                    )
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingHelp) {
            if #available(iOS 16.0, *) {
                QiblaHelpView()
                    .presentationDetents([.medium])
            } else {
                QiblaHelpView()
            }
        }
    }
    
    private func compassDirection(for angle: Double) -> String {
        switch angle {
        case 0: return "N"
        case 45: return "NE"
        case 90: return "E"
        case 135: return "SE"
        case 180: return "S"
        case 225: return "SW"
        case 270: return "W"
        case 315: return "NW"
        default: return ""
        }
    }
}

struct QiblaHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                IslamicTheme.primaryGradient
                    .ignoresSafeArea()
                    .overlay(
                        IslamicPatternView(color: .white, opacity: 0.05)
                            .ignoresSafeArea()
                    )
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Use Qibla Finder")
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        InstructionRow(number: "1", text: "Hold your phone flat in your palm")
                        InstructionRow(number: "2", text: "Make sure you're away from magnetic interference")
                        InstructionRow(number: "3", text: "Rotate yourself until the Kaaba image points north")
                        InstructionRow(number: "4", text: "The arrow indicates the direction of the Qibla")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.1))
                    )
                    
                    Text("Note: This is an approximate direction. For precise prayer alignment, please consult your local mosque.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(number)
                .font(.system(.headline, design: .serif))
                .foregroundColor(IslamicTheme.accentColor)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
            
            Text(text)
                .font(.system(.body, design: .serif))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}
