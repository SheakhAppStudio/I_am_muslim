import SwiftUI
import WidgetKit

struct CircularPrayerView: View {
    let entry: PrayerWidgetEntry
    
    // Calculate time remaining until next prayer
    private var timeRemaining: TimeInterval {
        entry.nextPrayerTime.timeIntervalSince(entry.date)
    }
    
    // Calculate progress for the circle (inverted for countdown)
    private var progress: Double {
        let totalInterval: TimeInterval = 5 * 60 * 60 // 5 hours as max interval
        return 1 - min(max(timeRemaining / totalInterval, 0), 1)
    }
    
    private var progressColor: Color {
        let percentage = progress * 100
        if percentage >= 75 {
            return .red.opacity(0.8)
        } else if percentage >= 50 {
            return .orange.opacity(0.8)
        } else {
            return IslamicTheme.accentColor
        }
    }
    
    var body: some View {
        ZStack {
            // Base gradient background
            Circle()
                .fill(LinearGradient(
                    colors: [Color.black.opacity(0.1), Color.black.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
            
            // Outer progress ring
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 10)
            
            // Progress ring with dynamic color
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: StrokeStyle(
                    lineWidth: 10,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
            
            // Inner ring for depth effect
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)
                .padding(4)
            
            // Content container with background
            ZStack {
                // Circular gradient background
                Circle()
                    .fill(LinearGradient(
                        colors: [
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 110, height: 110) // Slightly smaller than the progress ring
                
                // White glow for better contrast
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .blur(radius: 3)
                    .frame(width: 100, height: 100)
                
                // Content layout
                VStack(spacing: 1) {
                    // Prayer name with icon
                    HStack(spacing: 3) {
                        Image(systemName: getPrayerIcon(entry.nextPrayer))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(progressColor)
                            .symbolRenderingMode(.hierarchical)
                        
                        Text(entry.nextPrayer)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(progressColor)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }
                    .padding(.top, 1)
                    
                    // Time display
                    Text(formatTime(entry.nextPrayerTime))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        .padding(.bottom, 1)
                }
                .frame(width: 80) // Smaller width constraint
            }
            .frame(width: 120, height: 120)
        }
    }
    
    // Format remaining time as "XXm" or "Xh XXm"
    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

    
    // Format remaining time as "XX min" or "X hr XX min"
    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Get appropriate icon for each prayer time
    private func getPrayerIcon(_ prayer: String) -> String {
        switch prayer.lowercased() {
        case "fajr":
            return "sunrise.fill"
        case "sunrise":
            return "sun.horizon.fill"
        case "dhuhr":
            return "sun.max.fill"
        case "asr":
            return "sun.min.fill"
        case "maghrib":
            return "sunset.fill"
        case "isha":
            return "moon.stars.fill"
        default:
            return "clock.fill"
        }
    }


// Preview provider
struct CircularPrayerView_Previews: PreviewProvider {
    static var previews: some View {
        CircularPrayerView(entry: .placeholder)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
