//
//  PrayerAPIService.swift
//  I am Muslim Watch App Watch App
//
//  Created by Cascade AI on 25/04/2025.
//

import Foundation
import CoreLocation

class PrayerAPIService {
    static let shared = PrayerAPIService()
    private let baseURL = "https://api.aladhan.com/v1/timings"
    private var currentTask: URLSessionDataTask?
    private let cache = NSCache<NSString, NSArray>()
    private let cacheKey = "prayer_times_watch"
    
    // Add these properties for caching
    private let defaults = UserDefaults.standard
    private let lastFetchDateKey = "last_prayer_fetch_date_watch"
    private let lastFetchLocationKey = "last_prayer_fetch_location_watch"
    private let cacheDuration: TimeInterval = 12 * 3600 // 12 hours in seconds
    
    private init() {}
    
    func fetchPrayerTimes(for location: CLLocation, forceRefresh: Bool = false) async throws -> [PrayerTime] {
        print("\n=== Starting Prayer Time Fetch for Watch ===")
        
        // Check cache first if not forcing refresh
        if !forceRefresh, let cachedPrayers = try await getCachedPrayerTimes(for: location) {
            print("Using cached prayer times")
            return cachedPrayers
        }
        
        // Construct URL with parameters
        var components = URLComponents(string: baseURL)
        
        // Default to ISNA calculation method
        let methodValue = 2 // ISNA
        let asrValue = 0    // Standard (Shafi)
        
        // Get current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: Date())
        
        // Set query parameters
        let queryItems = [
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "method", value: String(methodValue)),
            URLQueryItem(name: "asr", value: String(asrValue)),
            URLQueryItem(name: "date", value: dateString),
            URLQueryItem(name: "tune", value: "0,0,0,0,0,0,0,0,0")
        ]
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        print("Fetching prayer times from: \(url)")
        
        // Create and execute request
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        
        // Use async/await for network request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode response
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(PrayerAPIResponse.self, from: data)
        
        // Create prayer time objects
        let prayers = createPrayerTimes(from: apiResponse.data.timings)
        
        // Cache the results
        cachePrayerTimes(prayers, for: location)
        
        return prayers
    }
    
    private func createPrayerTimes(from timings: PrayerTimings) -> [PrayerTime] {
        var prayers: [PrayerTime] = []
        
        // Convert time strings to dates
        if let fajrTime = convertTimeString(timings.Fajr) {
            prayers.append(PrayerTime(name: "Fajr", time: fajrTime, arabicName: "الفجر"))
        }
        
        if let dhuhrTime = convertTimeString(timings.Dhuhr) {
            prayers.append(PrayerTime(name: "Dhuhr", time: dhuhrTime, arabicName: "الظهر"))
        }
        
        if let asrTime = convertTimeString(timings.Asr) {
            prayers.append(PrayerTime(name: "Asr", time: asrTime, arabicName: "العصر"))
        }
        
        if let maghribTime = convertTimeString(timings.Maghrib) {
            prayers.append(PrayerTime(name: "Maghrib", time: maghribTime, arabicName: "المغرب"))
        }
        
        if let ishaTime = convertTimeString(timings.Isha) {
            prayers.append(PrayerTime(name: "Isha", time: ishaTime, arabicName: "العشاء"))
        }
        
        // Sort prayers by time
        return prayers.sorted { $0.time < $1.time }
    }
    
    private func convertTimeString(_ timeString: String) -> Date? {
        // Create date formatter for HH:mm format
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
            
            if let finalDate = calendar.date(from: dateComponents) {
                return finalDate
            }
        }
        
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
