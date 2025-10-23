import Foundation

struct PrayerTimes {
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
}

class PrayerService {
    static let shared = PrayerService()
    
    private let userDefaults = UserDefaults(suiteName: "group.com.sheakhemon.iammuslim")
    private let calendar = Calendar.current
    
    private init() {}
    
    func getPrayerTimes(for date: Date) async -> PrayerTimes {
        // For now, return mock data. You'll need to integrate with your actual prayer calculation logic
        if let storedTimes = loadPrayerTimesFromUserDefaults(for: date) {
            return storedTimes
        }
        
        return createMockPrayerTimes(for: date)
    }
    
    func getNextPrayer(from prayers: PrayerTimes) -> String {
        let now = Date()
        
        if now < prayers.fajr { return "Fajr" }
        if now < prayers.sunrise { return "Sunrise" }
        if now < prayers.dhuhr { return "Dhuhr" }
        if now < prayers.asr { return "Asr" }
        if now < prayers.maghrib { return "Maghrib" }
        if now < prayers.isha { return "Isha" }
        
        return "Fajr" // Next day's Fajr
    }
    
    func getNextPrayerTime(from prayers: PrayerTimes) -> Date {
        let now = Date()
        
        if now < prayers.fajr { return prayers.fajr }
        if now < prayers.sunrise { return prayers.sunrise }
        if now < prayers.dhuhr { return prayers.dhuhr }
        if now < prayers.asr { return prayers.asr }
        if now < prayers.maghrib { return prayers.maghrib }
        if now < prayers.isha { return prayers.isha }
        
        // Return next day's Fajr time
        return calendar.date(byAdding: .day, value: 1, to: prayers.fajr) ?? now
    }
    
    // MARK: - Private Methods
    
    private func loadPrayerTimesFromUserDefaults(for date: Date) -> PrayerTimes? {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: dateKey(for: date)),
              let times = try? JSONDecoder().decode(CachedPrayerTimes.self, from: data)
        else {
            return nil
        }
        
        return PrayerTimes(
            fajr: times.fajr,
            sunrise: times.sunrise,
            dhuhr: times.dhuhr,
            asr: times.asr,
            maghrib: times.maghrib,
            isha: times.isha
        )
    }
    
    private func savePrayerTimesToUserDefaults(_ times: PrayerTimes, for date: Date) {
        let cached = CachedPrayerTimes(
            fajr: times.fajr,
            sunrise: times.sunrise,
            dhuhr: times.dhuhr,
            asr: times.asr,
            maghrib: times.maghrib,
            isha: times.isha
        )
        
        guard let userDefaults = userDefaults,
              let data = try? JSONEncoder().encode(cached)
        else {
            return
        }
        
        userDefaults.set(data, forKey: dateKey(for: date))
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "prayer_times_\(formatter.string(from: date))"
    }
    
    private func createMockPrayerTimes(for date: Date) -> PrayerTimes {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Set mock prayer times
        components.hour = 5
        components.minute = 30
        let fajr = calendar.date(from: components) ?? date
        
        components.hour = 6
        components.minute = 45
        let sunrise = calendar.date(from: components) ?? date
        
        components.hour = 12
        components.minute = 15
        let dhuhr = calendar.date(from: components) ?? date
        
        components.hour = 15
        components.minute = 30
        let asr = calendar.date(from: components) ?? date
        
        components.hour = 18
        components.minute = 0
        let maghrib = calendar.date(from: components) ?? date
        
        components.hour = 19
        components.minute = 30
        let isha = calendar.date(from: components) ?? date
        
        return PrayerTimes(
            fajr: fajr,
            sunrise: sunrise,
            dhuhr: dhuhr,
            asr: asr,
            maghrib: maghrib,
            isha: isha
        )
    }
}

// MARK: - Models for Caching

private struct CachedPrayerTimes: Codable {
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
}
