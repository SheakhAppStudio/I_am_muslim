import SwiftUI

struct PrayerTimeRow: View {
    let prayer: PrayerTime
    let isNext: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(prayer.name)
                    .font(.headline)
                    .foregroundColor(isNext ? ThemeColors.primary : ThemeColors.text)
                Text(prayer.arabicName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(prayer.timeString)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(isNext ? ThemeColors.primary : ThemeColors.text)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isNext ? ThemeColors.cardBackground : Color.clear)
                .shadow(color: isNext ? Color.black.opacity(0.05) : .clear, radius: 5, x: 0, y: 2)
        )
    }
}
