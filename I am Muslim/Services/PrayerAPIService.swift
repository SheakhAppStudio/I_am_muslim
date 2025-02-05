import Foundation
import CoreLocation

struct PrayerAPIResponse: Codable {
    let code: Int
    let status: String
    let data: PrayerData
}

struct PrayerData: Codable {
    let timings: PrayerTimings
    let date: DateInfo
    let meta: Meta?
}

struct Meta: Codable {
    let latitude: Double?
    let longitude: Double?
    let timezone: String?
}

struct PrayerTimings: Codable {
    let Fajr: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
    
    private enum CodingKeys: String, CodingKey {
        case Fajr, Dhuhr, Asr, Maghrib, Isha
    }
    
    init(from decoder: Decoder) throws {
        print("\n=== Decoding Prayer Timings ===")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Clean and decode each timing
        let rawFajr = try container.decode(String.self, forKey: .Fajr)
        let rawDhuhr = try container.decode(String.self, forKey: .Dhuhr)
        let rawAsr = try container.decode(String.self, forKey: .Asr)
        let rawMaghrib = try container.decode(String.self, forKey: .Maghrib)
        let rawIsha = try container.decode(String.self, forKey: .Isha)
        
        print("Raw times from API:")
        print("Fajr: \(rawFajr)")
        print("Dhuhr: \(rawDhuhr)")
        print("Asr: \(rawAsr)")
        print("Maghrib: \(rawMaghrib)")
        print("Isha: \(rawIsha)")
        
        // Clean each time string
        Fajr = PrayerTimings.cleanTimeString(rawFajr)
        Dhuhr = PrayerTimings.cleanTimeString(rawDhuhr)
        Asr = PrayerTimings.cleanTimeString(rawAsr)
        Maghrib = PrayerTimings.cleanTimeString(rawMaghrib)
        Isha = PrayerTimings.cleanTimeString(rawIsha)
        
        print("\nCleaned times:")
        print("Fajr: \(Fajr)")
        print("Dhuhr: \(Dhuhr)")
        print("Asr: \(Asr)")
        print("Maghrib: \(Maghrib)")
        print("Isha: \(Isha)")
    }
    
    static func cleanTimeString(_ timeString: String) -> String {
        // For ISO8601 format, just return the original string
        return timeString
    }
}

struct DateInfo: Codable {
    let readable: String
    let timestamp: String?
}

class PrayerAPIService {
    static let shared = PrayerAPIService()
    private let baseURL = "https://api.aladhan.com/v1/timings"
    private var currentTask: URLSessionDataTask?
    private let cache = NSCache<NSString, NSArray>()
    private let cacheKey = "prayer_times"
    
    // Add these properties for caching
    private let defaults = UserDefaults.standard
    private let lastFetchDateKey = "last_prayer_fetch_date"
    private let lastFetchLocationKey = "last_prayer_fetch_location"
    private let cacheDuration: TimeInterval = 12 * 3600 // 12 hours in seconds
    
    private init() {}
    
    private func convertPrayerTime(_ timeString: String) -> Date? {
        print("Converting time string: \(timeString)")
        
        // Create date formatter for ISO8601 time
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // First try parsing as ISO8601
        if let date = formatter.date(from: timeString) {
            print("Successfully parsed ISO8601 date: \(date)")
            return date
        }
        
        // If not ISO8601, try HH:mm format
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone.current
        
        // Get today's date components
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        if let time = timeFormatter.date(from: timeString) {
            // Get the time components
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            
            // Combine with today's date
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.second = 0
            
            if let finalDate = calendar.date(from: dateComponents) {
                print("Successfully converted \(timeString) to: \(finalDate)")
                return finalDate
            }
        }
        
        print("Failed to convert time string: \(timeString)")
        return nil
    }
    
    private func verifyPrayerTimes(_ prayers: [PrayerTime]) {
        print("\n=== Prayer Time Verification ===")
        
        // Get current time
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        // Sort prayers by time
        let sortedPrayers = prayers.sorted { $0.time < $1.time }
        
        // Verify time ranges
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone.current
        
        print("\nTime Range Verification:")
        
        // Fajr should be early morning (typically between 4-7 AM)
        if let fajr = sortedPrayers.first(where: { $0.name == "Fajr" }) {
            let fajrHour = calendar.component(.hour, from: fajr.time)
            print("- Fajr (\(timeFormatter.string(from: fajr.time))): \(fajrHour >= 3 && fajrHour <= 7 ? "✅ Valid" : "⚠️ Unusual time")")
        }
        
        // Dhuhr should be around noon (typically between 12-2 PM)
        if let dhuhr = sortedPrayers.first(where: { $0.name == "Dhuhr" }) {
            let dhuhrHour = calendar.component(.hour, from: dhuhr.time)
            print("- Dhuhr (\(timeFormatter.string(from: dhuhr.time))): \(dhuhrHour >= 11 && dhuhrHour <= 14 ? "✅ Valid" : "⚠️ Unusual time")")
        }
        
        // Asr should be afternoon (typically between 2-5 PM)
        if let asr = sortedPrayers.first(where: { $0.name == "Asr" }) {
            let asrHour = calendar.component(.hour, from: asr.time)
            print("- Asr (\(timeFormatter.string(from: asr.time))): \(asrHour >= 14 && asrHour <= 17 ? "✅ Valid" : "⚠️ Unusual time")")
        }
        
        // Maghrib should be around sunset (typically between 5-8 PM)
        if let maghrib = sortedPrayers.first(where: { $0.name == "Maghrib" }) {
            let maghribHour = calendar.component(.hour, from: maghrib.time)
            print("- Maghrib (\(timeFormatter.string(from: maghrib.time))): \(maghribHour >= 16 && maghribHour <= 20 ? "✅ Valid" : "⚠️ Unusual time")")
        }
        
        // Isha should be night (typically between 7-10 PM)
        if let isha = sortedPrayers.first(where: { $0.name == "Isha" }) {
            let ishaHour = calendar.component(.hour, from: isha.time)
            print("- Isha (\(timeFormatter.string(from: isha.time))): \(ishaHour >= 18 && ishaHour <= 23 ? "✅ Valid" : "⚠️ Unusual time")")
        }
        
        // Verify order
        print("\nPrayer Order Verification:")
        let correctOrder = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        let actualOrder = sortedPrayers.map { $0.name }
        let orderIsCorrect = actualOrder == correctOrder
        print(orderIsCorrect ? "✅ Prayers are in correct order" : "❌ Prayer order is incorrect")
        
        // Verify intervals
        print("\nPrayer Interval Verification:")
        for i in 0..<sortedPrayers.count-1 {
            let current = sortedPrayers[i]
            let next = sortedPrayers[i+1]
            let interval = calendar.dateComponents([.hour], from: current.time, to: next.time).hour ?? 0
            print("- \(current.name) to \(next.name): \(interval) hours \(interval >= 2 && interval <= 7 ? "✅" : "⚠️")")
        }
    }
    
    func fetchPrayerTimes(for location: CLLocation, forceRefresh: Bool = false) async throws -> [PrayerTime] {
        print("\n=== Starting Prayer Time Fetch ===")
        print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Check if we should use cached data
        if !forceRefresh, let cachedPrayers = try? await getCachedPrayerTimes(for: location) {
            print("Using cached prayer times")
            return cachedPrayers
        }
        
        // Cancel any existing request
        currentTask?.cancel()
        
        // Get current settings
        let settings = PrayerSettingsManager.shared.settings
        print("\nSettings:")
        print("- Calculation Method: \(settings.calculationMethod.description)")
        print("- Asr Method: \(settings.asrCalculation.description)")
        print("- Adjustments: Fajr(\(settings.fajrAdjustment)), Dhuhr(\(settings.dhuhrAdjustment)), Asr(\(settings.asrAdjustment)), Maghrib(\(settings.maghribAdjustment)), Isha(\(settings.ishaAdjustment))")
        
        // Construct URL with parameters
        var components = URLComponents(string: baseURL)
        
        // Convert calculation method to API value
        let methodValue: Int
        switch settings.calculationMethod {
            case .isna: methodValue = 2      // ISNA
            case .mwl: methodValue = 3       // Muslim World League
            case .egyptian: methodValue = 5   // Egyptian
            case .karachi: methodValue = 1    // Karachi
            case .makkah: methodValue = 4     // Makkah
            case .tehran: methodValue = 7     // Tehran
            case .shia: methodValue = 0       // Shia Ithna Ashari
            case .gulf: methodValue = 8       // Gulf Region
        }
        
        // Convert Asr method to API value (0 = Shafi/Standard, 1 = Hanafi)
        let asrValue = settings.asrCalculation == .hanafi ? 1 : 0
        
        // Get current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: Date())
        
        print("\nAPI Parameters:")
        print("- Method: \(methodValue) (\(settings.calculationMethod.name))")
        print("- Asr Method: \(asrValue) (\(settings.asrCalculation.name))")
        print("- Date: \(dateString)")
        
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(format: "%.6f", location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(format: "%.6f", location.coordinate.longitude)),
            URLQueryItem(name: "method", value: String(methodValue)),
            URLQueryItem(name: "school", value: String(asrValue)),
            URLQueryItem(name: "date", value: dateString),
            URLQueryItem(name: "tune", value: [
                settings.imsakAdjustment,
                settings.fajrAdjustment,
                settings.sunriseAdjustment,
                settings.dhuhrAdjustment,
                settings.asrAdjustment,
                settings.maghribAdjustment,
                settings.ishaAdjustment
            ].map(String.init).joined(separator: ",")),
            URLQueryItem(name: "iso8601", value: "true"),
            URLQueryItem(name: "midnightMode", value: "0"),
            URLQueryItem(name: "timezonestring", value: TimeZone.current.identifier)
        ]
        
        guard let url = components?.url else {
            print("Failed to construct URL")
            throw URLError(.badURL)
        }
        
        print("\nAPI Request URL: \(url.absoluteString)")
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                // Clear the current task
                self?.currentTask = nil
                
                // Handle cancellation
                if let error = error as NSError?, error.code == NSURLErrorCancelled {
                    print("Request was cancelled - this is expected when refreshing")
                    return // Don't call continuation for cancelled requests
                }
                
                // Handle other errors
                if let error = error {
                    print("Error fetching prayer times: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                // Handle response
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]))
                    return
                }
                
                print("\nAPI Response Status: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    print("Invalid response code: \(httpResponse.statusCode)")
                    continuation.resume(throwing: NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response code: \(httpResponse.statusCode)"]))
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(PrayerAPIResponse.self, from: data)
                    
                    let timings = response.data.timings
                    
                    // Create prayer times
                    var prayers: [PrayerTime] = []
                    
                    print("\nRaw Prayer Times from API:")
                    print("- Fajr: \(timings.Fajr)")
                    print("- Dhuhr: \(timings.Dhuhr)")
                    print("- Asr: \(timings.Asr)")
                    print("- Maghrib: \(timings.Maghrib)")
                    print("- Isha: \(timings.Isha)")
                    
                    if let fajr = self?.createPrayerTime(name: "Fajr", arabicName: "الفجر", timeString: timings.Fajr) {
                        prayers.append(fajr)
                    }
                    if let dhuhr = self?.createPrayerTime(name: "Dhuhr", arabicName: "الظهر", timeString: timings.Dhuhr) {
                        prayers.append(dhuhr)
                    }
                    if let asr = self?.createPrayerTime(name: "Asr", arabicName: "العصر", timeString: timings.Asr) {
                        prayers.append(asr)
                    }
                    if let maghrib = self?.createPrayerTime(name: "Maghrib", arabicName: "المغرب", timeString: timings.Maghrib) {
                        prayers.append(maghrib)
                    }
                    if let isha = self?.createPrayerTime(name: "Isha", arabicName: "العشاء", timeString: timings.Isha) {
                        prayers.append(isha)
                    }
                    
                    if prayers.count == 5 {
                        let sortedPrayers = prayers.sorted { $0.time < $1.time }
                        self?.verifyPrayerTimes(sortedPrayers)
                        
                        print("\nConverted Prayer Times (Local Time):")
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "h:mm a"
                        timeFormatter.timeZone = TimeZone.current
                        sortedPrayers.forEach { prayer in
                            print("- \(prayer.name): \(timeFormatter.string(from: prayer.time))")
                        }
                        
                        // Schedule notifications on main thread
                        DispatchQueue.main.async {
                            print("\n=== Scheduling Prayer Notifications ===")
                            print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                            print("Number of prayers to schedule: \(sortedPrayers.count)")
                            
                            NotificationManager.shared.schedulePrayerNotifications(for: sortedPrayers)
                            
                            // Use DispatchQueue instead of Task.sleep
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                self?.cachePrayerTimes(sortedPrayers, for: location)
                                continuation.resume(returning: sortedPrayers)
                            }
                        }
                    } else {
                        print("Failed to parse all prayer times")
                        continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse all prayer times"]))
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
            
            // Store and start the task
            self.currentTask = task
            task.resume()
        }
    }
    
    private func createPrayerTime(name: String, arabicName: String, timeString: String) -> PrayerTime? {
        print("\n=== Creating Prayer Time for \(name) ===")
        print("Input time string: \(timeString)")
        
        // Create ISO8601 formatter
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        
        // Try parsing as ISO8601 first
        if let date = iso8601Formatter.date(from: timeString) {
            print("Successfully parsed ISO8601 date: \(date)")
            
            // Convert to local time zone
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            
            if let localDate = calendar.date(from: components) {
                print("Converted to local time: \(localDate)")
                let prayer = PrayerTime(name: name, time: localDate, jamahTime: nil, arabicName: arabicName)
                
                // Format time for logging
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                timeFormatter.timeZone = TimeZone.current
                print("Created prayer time: \(name) at \(timeFormatter.string(from: localDate))")
                
                return prayer
            }
        }
        
        print("❌ Failed to parse ISO8601 time: \(timeString)")
        return nil
    }
    
    private func getCachedPrayerTimes(for location: CLLocation) async throws -> [PrayerTime]? {
        // Get last fetch info
        let lastFetchDate = defaults.object(forKey: lastFetchDateKey) as? Date ?? .distantPast
        let lastLat = defaults.double(forKey: "\(lastFetchLocationKey)_lat")
        let lastLong = defaults.double(forKey: "\(lastFetchLocationKey)_long")
        let lastLocation = CLLocation(latitude: lastLat, longitude: lastLong)
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if cache is valid:
        // 1. Cache is from today
        // 2. Less than 12 hours old
        // 3. Location hasn't changed significantly (100m threshold)
        let isToday = calendar.isDate(lastFetchDate, inSameDayAs: now)
        let isFresh = now.timeIntervalSince(lastFetchDate) < cacheDuration
        let locationChanged = location.distance(from: lastLocation) > 100
        
        print("\n=== Checking Cache Validity ===")
        print("Last fetch: \(lastFetchDate)")
        print("Is today: \(isToday)")
        print("Is fresh: \(isFresh)")
        print("Location changed: \(locationChanged)")
        
        if isToday && isFresh && !locationChanged {
            if let cachedData = cache.object(forKey: cacheKey as NSString) as? [PrayerTime] {
                return cachedData
            }
            
            // Try loading from UserDefaults if not in memory cache
            if let savedData = defaults.data(forKey: cacheKey),
               let decodedPrayers = try? JSONDecoder().decode([PrayerTime].self, from: savedData) {
                // Store in memory cache for faster subsequent access
                cache.setObject(decodedPrayers as NSArray, forKey: cacheKey as NSString)
                return decodedPrayers
            }
        }
        
        return nil
    }
    
    private func cachePrayerTimes(_ prayers: [PrayerTime], for location: CLLocation) {
        // Save to memory cache
        cache.setObject(prayers as NSArray, forKey: cacheKey as NSString)
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(prayers) {
            defaults.set(encoded, forKey: cacheKey)
            defaults.set(Date(), forKey: lastFetchDateKey)
            defaults.set(location.coordinate.latitude, forKey: "\(lastFetchLocationKey)_lat")
            defaults.set(location.coordinate.longitude, forKey: "\(lastFetchLocationKey)_long")
        }
        
        print("\n=== Prayer Times Cached ===")
        print("Cache time: \(Date())")
        print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
}
