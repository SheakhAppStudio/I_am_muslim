import Foundation
import CoreLocation

struct PrayerTime: Identifiable, Codable {
    let id = UUID()
    let name: String
    let time: Date
    let jamahTime: Date?
    let arabicName: String
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: time)
    }
    
    var jamahTimeString: String? {
        guard let jamahTime = jamahTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: jamahTime)
    }
    
    var hasJamahTime: Bool {
        jamahTime != nil
    }
    
    func jamahTimeDescription() -> String? {
        guard let jamahTime = jamahTime else { return nil }
        
        let minutes = Calendar.current.dateComponents([.minute], from: time, to: jamahTime).minute ?? 0
        if minutes == 0 {
            return "Jamah at start time"
        } else {
            return "Jamah after \(minutes) mins"
        }
    }
    
    var timeRemaining: String {
        let calendar = Calendar.current
        let now = Date()
        
        if now > time {
            // If it's past this prayer time, calculate time until next occurrence
            var nextOccurrence = time
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: time) {
                nextOccurrence = tomorrow
            }
            
            let components = calendar.dateComponents([.hour, .minute], from: now, to: nextOccurrence)
            guard let hours = components.hour, let minutes = components.minute else { return "Passed" }
            
            if hours > 0 {
                return "\(hours)h \(minutes)m until next"
            } else {
                return "\(minutes)m until next"
            }
        }
        
        let components = calendar.dateComponents([.hour, .minute], from: now, to: time)
        guard let hours = components.hour, let minutes = components.minute else { return "" }
        
        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else {
            return "\(minutes)m remaining"
        }
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: time)
    }
}

// MARK: - ViewModel
@MainActor
class PrayerTimesViewModel: ObservableObject {
    static let shared = PrayerTimesViewModel()
    
    @Published private(set) var prayers: [PrayerTime] = []
    @Published private(set) var nextPrayer: PrayerTime?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var locationName: String = "Loading..."
    
    private let locationManager: LocationManager
    private let notificationManager = NotificationManager.shared
    private var backgroundTask: Task<Void, Never>?
    @Published private(set) var lastFetchDate: Date?
    private let userDefaults = UserDefaults.standard
    private let prayerTimesKey = "cached_prayer_times"
    private let lastFetchKey = "last_fetch_date"
    private var updateTimer: Timer?
    @Published private(set) var usingMosqueTimes: Bool = false
    private var mosqueUpdateTimer: Timer?
    private var selectedMosqueId: String?
    
    private init() {
        self.locationManager = LocationManager()
        
        // Load cached data and mosque state
        loadCachedData()
        self.usingMosqueTimes = userDefaults.bool(forKey: "using_mosque_times")
        self.selectedMosqueId = userDefaults.string(forKey: "selected_mosque_id")
        
        // Setup appropriate timers and updates based on state
        if usingMosqueTimes {
            setupMosqueUpdates()
        } else {
            setupLocationUpdates()
            startBackgroundRefresh()
            setupTimer()
        }
        
        setupSettingsObserver()
    }
    
    func setPrayerTimes(_ newPrayers: [PrayerTime], isMosqueTimes: Bool = false, mosqueId: String? = nil) {
        self.usingMosqueTimes = isMosqueTimes
        self.selectedMosqueId = mosqueId
        self.prayers = newPrayers
        self.updateNextPrayer()
        
        // Schedule notifications for the new prayer times
        notificationManager.removeAllPendingNotifications()
        notificationManager.schedulePrayerNotifications(for: newPrayers)
        
        // Save mosque selection state
        userDefaults.set(isMosqueTimes, forKey: "using_mosque_times")
        if let mosqueId = mosqueId {
            userDefaults.set(mosqueId, forKey: "selected_mosque_id")
        }
        
        self.cacheData()
        
        // If using mosque times, stop location updates and setup mosque updates
        if isMosqueTimes {
            locationManager.stopUpdatingLocation()
            backgroundTask?.cancel()
            updateTimer?.invalidate()
            updateTimer = nil
            setupMosqueUpdates()
        }
    }
    
    private func setupLocationUpdates() {
        // Request location immediately if we don't have cached data
        if prayers.isEmpty {
            locationManager.startUpdatingLocation()
        }
        
        locationManager.onLocationNameUpdate = { [weak self] name in
            self?.locationName = name
        }
        
        // Add observer for location changes
        NotificationCenter.default.addObserver(forName: .init("LocationDidUpdate"), object: nil, queue: .main) { [weak self] _ in
            Task { [weak self] in
                await self?.refreshPrayerTimes()
            }
        }
    }
    
    private func loadCachedData() {
        if let data = userDefaults.data(forKey: prayerTimesKey),
           let cachedPrayers = try? JSONDecoder().decode([PrayerTime].self, from: data) {
            self.prayers = cachedPrayers
            updateNextPrayer()
        }
        
        if let lastFetch = userDefaults.object(forKey: lastFetchKey) as? Date {
            self.lastFetchDate = lastFetch
        }
    }
    
    private func cacheData() {
        if let encoded = try? JSONEncoder().encode(prayers) {
            userDefaults.set(encoded, forKey: prayerTimesKey)
            userDefaults.set(Date(), forKey: lastFetchKey)
        }
    }
    
    private func startBackgroundRefresh() {
        backgroundTask?.cancel()
        backgroundTask = Task {
            while !Task.isCancelled {
                // Check if we need to refresh (at midnight or if last fetch was yesterday)
                let calendar = Calendar.current
                let now = Date()
                
                let shouldRefresh = lastFetchDate.map { lastFetch in
                    !calendar.isDate(lastFetch, inSameDayAs: now)
                } ?? true
                
                if shouldRefresh {
                    await refreshPrayerTimes()
                }
                
                // Wait until next check (every hour)
                try? await Task.sleep(nanoseconds: 60 * 60 * 1_000_000_000)
            }
        }
    }
    
    private func setupTimer() {
        // Update next prayer every minute
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateNextPrayer()
        }
    }
    
    private func setupSettingsObserver() {
        print("Setting up prayer settings observer")
        // Add observer for prayer settings changes
        NotificationCenter.default.addObserver(
            forName: .prayerSettingsChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("Received prayer settings changed notification")
            Task {
                print("Starting prayer times refresh due to settings change")
                // Clear cache to force refresh with new settings
                self?.lastFetchDate = nil
                self?.userDefaults.removeObject(forKey: self?.prayerTimesKey ?? "")
                await self?.refreshPrayerTimes(forceRefresh: true)
            }
        }
    }
    
    private func setupMosqueUpdates() {
        // Cancel any existing mosque update timer
        mosqueUpdateTimer?.invalidate()
        
        // Calculate time until next update (3:00 AM)
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 3
        components.minute = 0
        
        guard let nextUpdateTime = calendar.nextDate(after: Date(),
                                                    matching: components,
                                                    matchingPolicy: .nextTime) else {
            return
        }
        
        // Schedule the first update
        let timeInterval = nextUpdateTime.timeIntervalSince(Date())
        mosqueUpdateTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            Task {
                await self?.refreshMosquePrayerTimes()
            }
        }
    }
    
    private func refreshMosquePrayerTimes() async {
        guard usingMosqueTimes else { return }
        
        // Delay showing loading indicator to avoid flicker on fast loads
        let loadingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            if !Task.isCancelled {
                isLoading = true
            }
        }
        
        do {
            print("🕌 Fetching prayer times from mosque API...")
            let prayers = try await MosquePrayerService.shared.fetchBuryParkPrayerTimes(forceRefresh: true)
            await MainActor.run {
                self.setPrayerTimes(prayers, isMosqueTimes: true, mosqueId: selectedMosqueId)
                print("✅ Successfully updated mosque prayer times")
            }
        } catch {
            print("❌ Error refreshing mosque prayer times: \(error)")
            errorMessage = "Unable to fetch mosque prayer times. Please check your internet connection and try again."
        }
        
        loadingTask.cancel()
        await MainActor.run { isLoading = false }
        
        // Setup the next day's update
        setupMosqueUpdates()
    }
    
    func refreshPrayerTimes(forceRefresh: Bool = false) async {
        print("\n=== Refreshing Prayer Times ===")
        print("Force refresh: \(forceRefresh)")
        print("Current state - loading: \(isLoading), mosque times: \(usingMosqueTimes)")
        
        guard !isLoading else {
            print("⚠️ Already loading, skipping refresh")
            return
        }
        
        // If using mosque times, refresh from mosque API
        if usingMosqueTimes {
            print("🕌 Using mosque times, refreshing from mosque API")
            await refreshMosquePrayerTimes()
            return
        }
        
        // Delay showing loading indicator to avoid flicker on fast loads
        let loadingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            if !Task.isCancelled {
                isLoading = true
            }
        }
        
        errorMessage = nil
        
        // Clear cache if force refreshing
        if forceRefresh {
            print("🔄 Force refresh - clearing cache")
            lastFetchDate = nil
            userDefaults.removeObject(forKey: prayerTimesKey)
        }
        
        // Wait for location to be available
        for _ in 0..<3 { // Try up to 3 times
            if locationManager.location != nil {
                break
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
        }
        
        do {
            guard let location = locationManager.location else {
                print("No location available")
                
                // Check authorization status to provide more specific error message
                switch locationManager.authorizationStatus {
                case .denied, .restricted:
                    errorMessage = "Location access denied. Please enable location services for this app in Settings."
                case .notDetermined:
                    errorMessage = "Please allow location access to get prayer times for your area."
                default:
                    errorMessage = "Unable to get your location. Please ensure location services are enabled."
                }
                
                loadingTask.cancel()
        await MainActor.run { isLoading = false }
                return
            }
            
            print("📍 Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            print("📡 Calling prayer times API...")
            let newPrayers = try await PrayerAPIService.shared.fetchPrayerTimes(for: location, forceRefresh: forceRefresh)
            
            print("✅ Received \(newPrayers.count) prayer times from API")
            
            if !newPrayers.isEmpty {
                print("🔄 Updating prayer times...")
                self.prayers = newPrayers
                self.updateNextPrayer()
                if !forceRefresh { // Only cache if not force refreshing
                    print("💾 Caching new prayer times")
                    self.cacheData()
                }
                self.lastFetchDate = Date()
                self.errorMessage = nil
                print("✅ Prayer times updated successfully")
            } else {
                errorMessage = "No prayer times available for your location."
            }
        } catch {
            print("Error fetching prayer times: \(error.localizedDescription)")
            errorMessage = "Unable to fetch prayer times. Please check your internet connection and try again."
        }
        
        loadingTask.cancel()
        await MainActor.run { isLoading = false }
    }
    
    private func updateNextPrayer() {
        let now = Date()
        
        // Reset next prayer
        nextPrayer = nil
        
        // Find the next prayer
        for prayer in prayers {
            // If this prayer is later today, it could be next
            if prayer.time > now {
                if nextPrayer == nil {
                    nextPrayer = prayer
                    // Schedule notification for the next prayer
                    NotificationManager.shared.schedulePrayerNotifications(
                        for: [prayer],
                        usingMosque: usingMosqueTimes,
                        mosqueName: selectedMosqueId)
                }
            }
        }
        
        // If no next prayer found today, look at first prayer of next day
        if nextPrayer == nil && !prayers.isEmpty {
            nextPrayer = prayers[0]
            // Schedule notification for tomorrow's first prayer
            NotificationManager.shared.schedulePrayerNotifications(
                for: [prayers[0]],
                usingMosque: usingMosqueTimes,
                mosqueName: selectedMosqueId)
        }
    }
    
    func setCustomLocation(coordinate: CLLocationCoordinate2D, name: String) {
        locationManager.setCustomLocation(coordinate: coordinate, name: name)
        Task {
            await refreshPrayerTimes()
        }
    }
    
    func useCurrentLocation() {
        // Reset mosque settings
        usingMosqueTimes = false
        selectedMosqueId = nil
        mosqueUpdateTimer?.invalidate()
        mosqueUpdateTimer = nil
        
        // Clear cache to force refresh
        lastFetchDate = nil
        userDefaults.removeObject(forKey: prayerTimesKey)
        
        // Switch to current location
        locationManager.useCurrentLocation()
        Task {
            await refreshPrayerTimes(forceRefresh: true)
        }
    }
    
    deinit {
        backgroundTask?.cancel()
        updateTimer?.invalidate()
    }
}
