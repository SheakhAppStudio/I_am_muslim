import Foundation

struct MosquePrayerResponse: Codable {
    // Prayer begins times
    let fajr_begins: String
    let zuhr_begins: String
    let asr_mithl_1: String  // Using asr_mithl_1 for Asr begins time
    let maghrib_begins: String
    let isha_begins: String
    
    // Jamah times
    let fajr_jamah: String
    let zuhr_jamah: String
    let asr_jamah: String
    let maghrib_jamah: String
    let isha_jamah: String
    
    let d_date: String
}

enum MosquePrayerError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case noPrayerTimes
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid mosque URL"
        case .invalidResponse:
            return "Invalid response from mosque server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Error processing mosque data: \(error.localizedDescription)"
        case .noPrayerTimes:
            return "No prayer times available from mosque"
        }
    }
}

class MosquePrayerService {
    static let shared = MosquePrayerService()
    
    private let cache = NSCache<NSString, NSArray>()
    private let cacheKey = "bury_park_prayers"
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private init() {
        // Configure cache
        cache.countLimit = 1 // Only cache today's prayers
    }
    
    func fetchBuryParkPrayerTimes(forceRefresh: Bool = false) async throws -> [PrayerTime] {
        // Check cache first if not forcing refresh
        if !forceRefresh {
            if let cachedPrayers = checkCache() {
                print("✅ Using cached mosque prayer times")
                return cachedPrayers
            }
        }
        
        print("🔄 Fetching fresh mosque prayer times...")
        
        // Prepare URL
        guard let url = URL(string: "https://display.buryparkmasjid.co.uk/?rest_route=/dpt/v1/prayertime&filter=today") else {
            throw MosquePrayerError.invalidURL
        }
        
        // Configure URL session with longer timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 45  // Increased to 45 seconds
        config.timeoutIntervalForResource = 60 // Increased to 60 seconds
        config.waitsForConnectivity = true     // Wait for connectivity
        let session = URLSession(configuration: config)
        
        // Enhanced retry logic
        let maxRetries = 4  // Increased retries
        var lastError: Error? = nil
        
        // Exponential backoff delays: 5s, 10s, 20s, 40s
        let retryDelays = [5, 10, 20, 40]
        
        for attempt in 1...maxRetries {
            do {
                print("📡 Attempt \(attempt) of \(maxRetries)...")
                
                let (data, urlResponse) = try await session.data(from: url)
                
                // Validate response
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("❌ Invalid response type from mosque API")
                    throw MosquePrayerError.invalidResponse
                }
                
                // Log response details
                print("📝 Response status code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Invalid status code: \(httpResponse.statusCode)")
                    throw MosquePrayerError.invalidResponse
                }
                
                // Log response data
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📝 Response data: \(responseString)")
                }
                
                // Decode response
                let prayerResponse: [MosquePrayerResponse]
                do {
                    prayerResponse = try JSONDecoder().decode([MosquePrayerResponse].self, from: data)
                } catch let decodingError as DecodingError {
                    print("❌ JSON Decoding failed: \(decodingError)")
                    throw MosquePrayerError.decodingError(decodingError)
                }
                
                guard let todayPrayers = prayerResponse.first else {
                    print("❌ No prayer times in response")
                    throw MosquePrayerError.noPrayerTimes
                }
                
                // Get base date
                let baseDate = dateFormatter.date(from: todayPrayers.d_date) ?? Date()
                
                // Process and return prayer times
                let prayerTimes = createPrayerTimes(from: todayPrayers, baseDate: baseDate)
                cache.setObject(prayerTimes as NSArray, forKey: cacheKey as NSString)
                print("✅ Successfully fetched mosque prayer times")
                return prayerTimes
                
            } catch {
                lastError = error
                if attempt < maxRetries {
                    print("⚠️ Attempt \(attempt) failed: \(error.localizedDescription)")
                    try await Task.sleep(nanoseconds: UInt64(attempt * 2) * 1_000_000_000) // Exponential backoff
                    continue
                }
            }
        }
        
        // If we get here, all retries failed
        print("❌ All attempts to fetch mosque prayer times failed")
        throw lastError ?? MosquePrayerError.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed after \(maxRetries) attempts"]))
    }
    
    private func checkCache() -> [PrayerTime]? {
        print("🔍 Checking cache for mosque prayer times...")
        
        guard let cachedData = cache.object(forKey: cacheKey as NSString) as? [PrayerTime] else {
            print("⚠️ No cached data found")
            return nil
        }
        
        guard !cachedData.isEmpty else {
            print("⚠️ Cached data is empty")
            cache.removeObject(forKey: cacheKey as NSString)
            return nil
        }
        
        // Validate cache is for today
        let today = dateFormatter.string(from: Date())
        let cachedDate = dateFormatter.string(from: cachedData[0].time)
        
        print("📅 Today: \(today), Cached date: \(cachedDate)")
        
        guard today == cachedDate else {
            print("⚠️ Cache expired, need fresh data")
            cache.removeObject(forKey: cacheKey as NSString)
            return nil
        }
        
        print("✅ Found valid cached data with \(cachedData.count) prayer times")
        return cachedData
    }
    
    private func createDateTime(timeString: String, baseDate: Date) -> Date {
        // Split the time string into components
        let components = timeString.split(separator: ":")
        guard components.count >= 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            print("⚠️ Invalid time format: \(timeString)")
            return baseDate
        }
        
        // Create date components
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        // Create final date
        return calendar.date(from: dateComponents) ?? baseDate
    }
    
    private func createPrayerTimes(from response: MosquePrayerResponse, baseDate: Date) -> [PrayerTime] {
        return [
            PrayerTime(name: "Fajr", time: createDateTime(timeString: response.fajr_begins, baseDate: baseDate), jamahTime: createDateTime(timeString: response.fajr_jamah, baseDate: baseDate), arabicName: "الفجر"),
            PrayerTime(name: "Dhuhr", time: createDateTime(timeString: response.zuhr_begins, baseDate: baseDate), jamahTime: createDateTime(timeString: response.zuhr_jamah, baseDate: baseDate), arabicName: "الظهر"),
            PrayerTime(name: "Asr", time: createDateTime(timeString: response.asr_mithl_1, baseDate: baseDate), jamahTime: createDateTime(timeString: response.asr_jamah, baseDate: baseDate), arabicName: "العصر"),
            PrayerTime(name: "Maghrib", time: createDateTime(timeString: response.maghrib_begins, baseDate: baseDate), jamahTime: createDateTime(timeString: response.maghrib_jamah, baseDate: baseDate), arabicName: "المغرب"),
            PrayerTime(name: "Isha", time: createDateTime(timeString: response.isha_begins, baseDate: baseDate), jamahTime: createDateTime(timeString: response.isha_jamah, baseDate: baseDate), arabicName: "العشاء")
        ]
    }
}

