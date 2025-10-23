import WidgetKit
import SwiftUI

@main
struct PrayerTimesWidget: Widget {
    private let kind: String = "PrayerTimesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PrayerTimesWidgetView(entry: entry)
        }
        .configurationDisplayName("Prayer Times")
        .description("View today's prayer times at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}
