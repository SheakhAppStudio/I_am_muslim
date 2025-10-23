import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private let prayerService = PrayerService.shared
    
    func placeholder(in context: Context) -> PrayerWidgetEntry {
        PrayerWidgetEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PrayerWidgetEntry) -> Void) {
        Task {
            let entry = await getTimelineEntry()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        Task {
            let entry = await getTimelineEntry()
            print("[Widget Timeline] Created initial entry with next prayer: \(entry.nextPrayer) at \(entry.nextPrayerTime)")
            
            // Create a single timeline entry that updates at the next prayer time
            let nextUpdate = entry.nextPrayerTime
            print("[Widget Timeline] Setting next update for: \(nextUpdate)")
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            print("[Widget Timeline] Timeline created with 1 entry")
            
            completion(timeline)
        }
    }
    
    private func getTimelineEntry() async -> PrayerWidgetEntry {
        print("[Widget Timeline] Getting timeline entry...")
        let now = Date()
        let prayers = await prayerService.getPrayerTimes(for: now)
        
        let nextPrayer = prayerService.getNextPrayer(from: prayers)
        let nextPrayerTime = prayerService.getNextPrayerTime(from: prayers)
        
        // Calculate Tahajjud time (last third of the night)
        let calendar = Calendar.current
        let tahajjudTime: Date
        if let interval = calendar.dateInterval(of: .day, for: now) {
            // Get midnight
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = 0
            components.minute = 0
            components.second = 0
            
            if let midnight = calendar.date(from: components) {
                // Calculate duration between midnight and Fajr
                let nightDuration = prayers.fajr.timeIntervalSince(midnight)
                // Start of last third of night (optimal time for Tahajjud)
                tahajjudTime = midnight.addingTimeInterval(nightDuration * 2/3)
            } else {
                // Fallback: 2 hours before Fajr
                tahajjudTime = prayers.fajr.addingTimeInterval(-2 * 3600)
            }
        } else {
            // Fallback: 2 hours before Fajr
            tahajjudTime = prayers.fajr.addingTimeInterval(-2 * 3600)
        }
        
        print("[Widget Timeline] Prayer times:")
        print("- Fajr: \(prayers.fajr)")
        print("- Tahajjud: \(tahajjudTime)")
        print("- Dhuhr: \(prayers.dhuhr)")
        print("- Asr: \(prayers.asr)")
        print("- Maghrib: \(prayers.maghrib)")
        print("- Isha: \(prayers.isha)")
        print("Next prayer: \(nextPrayer) at \(nextPrayerTime)")
        
        let entry = PrayerWidgetEntry(
            date: now,
            fajr: prayers.fajr,
            tahajjud: tahajjudTime,
            dhuhr: prayers.dhuhr,
            asr: prayers.asr,
            maghrib: prayers.maghrib,
            isha: prayers.isha,
            nextPrayer: nextPrayer,
            nextPrayerTime: nextPrayerTime
        )
        
        print("[Widget Timeline] Created entry with next prayer: \(entry.nextPrayer)")
        return entry
    }
}
