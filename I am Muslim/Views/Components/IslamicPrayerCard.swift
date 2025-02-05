import SwiftUI

struct IslamicPrayerCard: View {
    let prayer: PrayerTime
    let isNext: Bool
    let isLarge: Bool
    @ObservedObject private var viewModel = PrayerTimesViewModel.shared
    
    init(prayer: PrayerTime, isNext: Bool, isLarge: Bool = false) {
        self.prayer = prayer
        self.isNext = isNext
        self.isLarge = isLarge
    }
    
    private var showJamahTimes: Bool {
        // Only show Jamah times in regular cards if it's not the next prayer
        return viewModel.usingMosqueTimes && prayer.hasJamahTime && !isNext
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Prayer Icon
            ZStack {
                Circle()
                    .fill(isNext ? IslamicTheme.accentColor : IslamicTheme.cardBackground)
                    .frame(width: isLarge ? 60 : 50, height: isLarge ? 60 : 50)
                    .shadow(color: IslamicTheme.shadowColor, radius: 5, x: 0, y: 2)
                
                Image(systemName: getPrayerIcon(for: prayer.name))
                    .font(isLarge ? .title : .title2)
                    .foregroundColor(isNext ? .white : IslamicTheme.accentColor)
            }
            
            VStack(alignment: .leading, spacing: isLarge ? 8 : 4) {
                // Prayer Name and Time
                HStack(spacing: 8) {
                    Text(prayer.name)
                        .font(.system(isLarge ? .title2 : .title3, design: .serif))
                        .fontWeight(.semibold)
                    
                    if isNext && !isLarge {
                        Text("• Next")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(IslamicTheme.upcomingPrayer)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(IslamicTheme.upcomingPrayer.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                    
                    if !isLarge {
                        Text(prayer.formattedTime)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(IslamicTheme.textColor)
                    }
                }
                
                // Arabic Name
                Text("صلاة \(prayer.arabicName)")
                    .font(.system(isLarge ? .title3 : .body, design: .serif))
                    .foregroundColor(IslamicTheme.textColor)
                
                if showJamahTimes {
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.vertical, 6)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .font(.system(.body))
                            .foregroundColor(IslamicTheme.accentColor)
                        
                        Text("Jamah at \(prayer.jamahTimeString ?? "")")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(IslamicTheme.accentColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(IslamicTheme.accentColor.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(IslamicTheme.accentColor.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                
                if isLarge {
                    VStack(spacing: 16) {
                        // Prayer time section
                        VStack(spacing: 12) {
                            Text(prayer.formattedTime)
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(IslamicTheme.textColor)
                            
                            if viewModel.usingMosqueTimes && prayer.hasJamahTime {
                                HStack(spacing: 8) {
                                    Image(systemName: "person.3.fill")
                                    Text("Jamah at \(prayer.jamahTimeString ?? "")")
                                }
                                .font(.system(.title3, design: .rounded))
                                .foregroundColor(IslamicTheme.accentColor)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "timer")
                                Text(prayer.timeRemaining)
                                    .fontWeight(.medium)
                            }
                            .font(.system(.title3, design: .rounded))
                            .foregroundColor(IslamicTheme.upcomingPrayer)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
        }
        .padding(isLarge ? 20 : 15)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: IslamicTheme.smallCornerRadius)
                    .fill(IslamicTheme.cardBackground)
                    .shadow(color: IslamicTheme.shadowColor, radius: 8, x: 0, y: 4)
                
                // Islamic Pattern overlay
                if isLarge {
                    IslamicPatternView(color: IslamicTheme.accentColor, opacity: 0.05)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: IslamicTheme.smallCornerRadius)
                .stroke(
                    isNext ? IslamicTheme.accentColor : Color.clear,
                    lineWidth: isNext ? 2 : 0
                )
        )
    }
    
    private func getPrayerIcon(for prayerName: String) -> String {
        switch prayerName.lowercased() {
        case "fajr":
            return "sunrise.fill"
        case "dhuhr":
            return "sun.max.fill"
        case "asr":
            return "sun.min.fill"
        case "maghrib":
            return "sunset.fill"
        case "isha":
            return "moon.stars.fill"
        default:
            return "sun.max.fill"
        }
    }
}
