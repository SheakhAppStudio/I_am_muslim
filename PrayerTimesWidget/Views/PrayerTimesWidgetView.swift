import SwiftUI
import WidgetKit

struct IslamicTheme {
    static let primaryGradient = LinearGradient(
        colors: [
            Color(hex: "1F4B6B"),
            Color(hex: "366C8F")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let accentColor = Color(hex: "C3934B") // Gold accent
    static let cardBackground = Color(hex: "FFFFFF")
    
    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.15),
            Color.white.opacity(0.1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let activeCardGradient = LinearGradient(
        colors: [
            accentColor.opacity(0.3),
            accentColor.opacity(0.15)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct PrayerTimesWidgetView: View {
    let entry: PrayerWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .accessoryCircular:
                CircularPrayerView(entry: entry)
            default:
                MediumWidgetView(entry: entry)
            }
        }
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

// Time formatting helper
func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: date)
}

extension View {
    func widgetBackground(_ background: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                IslamicTheme.primaryGradient
            }
        } else {
            return background
                .background(IslamicTheme.primaryGradient)
        }
    }
}

struct SmallWidgetView: View {
    let entry: PrayerWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(IslamicTheme.accentColor.opacity(0.8))
                    .font(.system(size: 12))
                Text(timeUntilNextPrayer)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Prayer Time
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.nextPrayer)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(IslamicTheme.accentColor)
                
                Text(formatTime(entry.nextPrayerTime))
                    .font(.title3)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
    }
    
    private var timeUntilNextPrayer: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date(), to: entry.nextPrayerTime)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "In \(hours)h \(minutes)m"
            } else {
                return "In \(minutes) minutes"
            }
        }
        
        return "Updated \(formatTime(entry.date))"
    }
}


struct MediumWidgetView: View {
    let entry: PrayerWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(IslamicTheme.accentColor.opacity(0.8))
                    .font(.system(size: 12))
                Text(timeUntilNextPrayer)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }
            
            // Prayer Times Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                PrayerTimeCard(name: "Fajr", time: entry.fajr, isNext: entry.nextPrayer == "Fajr")
                PrayerTimeCard(name: "Tahajjud", time: entry.tahajjud, isNext: entry.nextPrayer == "Tahajjud")
                PrayerTimeCard(name: "Dhuhr", time: entry.dhuhr, isNext: entry.nextPrayer == "Dhuhr")
                PrayerTimeCard(name: "Asr", time: entry.asr, isNext: entry.nextPrayer == "Asr")
                PrayerTimeCard(name: "Maghrib", time: entry.maghrib, isNext: entry.nextPrayer == "Maghrib")
                PrayerTimeCard(name: "Isha", time: entry.isha, isNext: entry.nextPrayer == "Isha")
            }
        }
        .padding(12)
    }
    
    private var timeUntilNextPrayer: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date(), to: entry.nextPrayerTime)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "Next: \(entry.nextPrayer) in \(hours)h \(minutes)m"
            } else {
                return "Next: \(entry.nextPrayer) in \(minutes)m"
            }
        }
        
        return entry.nextPrayer
    }
}


struct PrayerTimeCard: View {
    let name: String
    let time: Date
    let isNext: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 3) {
            Text(name)
                .font(.caption2)
                .foregroundColor(isNext ? IslamicTheme.accentColor : .white.opacity(0.9))
                .fontWeight(isNext ? .bold : .medium)
            
            Text(formatTime(time))
                .font(.system(size: 13))
                .foregroundColor(isNext ? IslamicTheme.accentColor : .white)
                .fontWeight(isNext ? .bold : .medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isNext ? IslamicTheme.activeCardGradient : IslamicTheme.cardGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isNext ? IslamicTheme.accentColor.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PrayerTimesWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrayerTimesWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            PrayerTimesWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
