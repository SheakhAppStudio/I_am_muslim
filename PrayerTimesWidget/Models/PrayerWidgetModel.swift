import Foundation
import WidgetKit

struct PrayerWidgetEntry: TimelineEntry {
    let date: Date
    let fajr: Date
    let tahajjud: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
    let nextPrayer: String
    let nextPrayerTime: Date
    
    static var placeholder: PrayerWidgetEntry {
        let now = Date()
        return PrayerWidgetEntry(
            date: now,
            fajr: now,
            tahajjud: now.addingTimeInterval(3600),
            dhuhr: now.addingTimeInterval(7200),
            asr: now.addingTimeInterval(10800),
            maghrib: now.addingTimeInterval(14400),
            isha: now.addingTimeInterval(18000),
            nextPrayer: "Fajr",
            nextPrayerTime: now.addingTimeInterval(21600)
        )
    }
}
