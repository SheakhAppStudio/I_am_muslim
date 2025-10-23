import Foundation

struct SharedPrayerTimes: Codable {
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
    let nextPrayer: String
    let lastUpdated: Date
}

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
    
    private let appGroupId = "group.com.sheakhemon.iammuslim"
    private let calendar = Calendar.current
    private let sharedKey = "widget.prayer.times"
    
    private var sharedContainer: FileManager {
        FileManager.default
    }
    
    private var sharedContainerURL: URL? {
        sharedContainer.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)
    }
    
    private init() {}
    
    func getPrayerTimes(for date: Date) async -> PrayerTimes {
        // Try to get prayer times from shared container
        if let prayerTimes = getPrayerTimesFromSharedContainer() {
            return prayerTimes
        }
        
        // Fallback to mock data if shared data is not available
        return createMockPrayerTimes(for: date)
    }
    
    private func getPrayerTimesFromSharedContainer() -> PrayerTimes? {
        print("[Widget] Attempting to read prayer times from shared container")
        
        guard let containerURL = sharedContainerURL else {
            print("[Widget] Failed to get shared container URL")
            return nil
        }
        print("[Widget] Got shared container URL: \(containerURL.path)")
        
        let fileURL = containerURL.appendingPathComponent(sharedKey)
        print("[Widget] Looking for file at: \(fileURL.path)")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("[Widget] File does not exist at path")
            return nil
        }
        print("[Widget] Found prayer times file")
        
        do {
            let data = try Data(contentsOf: fileURL)
            print("[Widget] Read \(data.count) bytes from file")
            
            let decoder = JSONDecoder()
            let sharedTimes = try decoder.decode(SharedPrayerTimes.self, from: data)
            print("[Widget] Successfully decoded prayer times")
            print("[Widget] Next prayer: \(sharedTimes.nextPrayer)")
            print("[Widget] Last updated: \(sharedTimes.lastUpdated)")
            
            // Verify data is from today
            guard calendar.isDateInToday(sharedTimes.lastUpdated) else {
                print("[Widget] Prayer times are not from today")
                return nil
            }
            print("[Widget] Prayer times are from today")
            
            let times = PrayerTimes(
                fajr: sharedTimes.fajr,
                sunrise: sharedTimes.sunrise,
                dhuhr: sharedTimes.dhuhr,
                asr: sharedTimes.asr,
                maghrib: sharedTimes.maghrib,
                isha: sharedTimes.isha
            )
            print("[Widget] Successfully created PrayerTimes")
            return times
        } catch {
            print("[Widget] Error reading/decoding prayer times: \(error)")
            return nil
        }
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
