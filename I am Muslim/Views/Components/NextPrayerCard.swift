import SwiftUI
import Combine

struct NextPrayerCard: View {
    let prayer: PrayerTime
    @State private var timeRemaining: String = ""
    @State private var currentTime = Date()
    @StateObject private var prayerTimesViewModel = PrayerTimesViewModel.shared
    @State private var timer: Timer.TimerPublisher?
    @State private var timerCancellable: AnyCancellable?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Next Prayer")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "clock.fill")
                    .foregroundColor(ThemeColors.primary)
            }
            
            VStack(spacing: 8) {
                Text(prayer.arabicName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(ThemeColors.primary)
                
                Text(prayer.name.uppercased())
                    .font(.title3)
                    .foregroundColor(ThemeColors.text)
            }
            
            VStack(spacing: 8) {
                Text(prayer.timeString)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(ThemeColors.primary)
                
                if prayerTimesViewModel.usingMosqueTimes && prayer.hasJamahTime {
                    HStack(spacing: 6) {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(ThemeColors.primary)
                        Text("Jamah at \(prayer.jamahTimeString ?? "")")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(ThemeColors.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ThemeColors.primary.opacity(0.1))
                    )
                }
            }
            
            // Time remaining indicator
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(ThemeColors.primary)
                Text(timeRemaining.isEmpty ? prayer.timeRemaining : timeRemaining)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .animation(.easeInOut, value: timeRemaining)
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(ThemeColors.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            startTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            stopTimer()
        }
    }
    
    private func startTimer() {
        stopTimer() // Stop any existing timer
        currentTime = Date()
        updateTimeRemaining()
        
        // Create and start new timer
        timer = Timer.publish(every: 1, on: .main, in: .common)
        timerCancellable = timer?.autoconnect().sink { _ in
            currentTime = Date()
            updateTimeRemaining()
        }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        timer = nil
    }
    
    private func updateTimeRemaining() {
        let calendar = Calendar.current
        let now = currentTime
        
        if now > prayer.time {
            // If it's past this prayer time, calculate time until next occurrence
            var nextOccurrence = prayer.time
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: prayer.time) {
                nextOccurrence = tomorrow
            }
            
            let interval = nextOccurrence.timeIntervalSince(now)
            let hours = Int(interval) / 3600
            let minutes = Int(interval) / 60 % 60
            let seconds = Int(interval) % 60
            
            if hours > 0 {
                timeRemaining = String(format: "%dh %02dm %02ds until next", hours, minutes, seconds)
            } else if minutes > 0 {
                timeRemaining = String(format: "%dm %02ds until next", minutes, seconds)
            } else {
                timeRemaining = String(format: "%ds until next", seconds)
            }
        } else {
            let interval = prayer.time.timeIntervalSince(now)
            let hours = Int(interval) / 3600
            let minutes = Int(interval) / 60 % 60
            let seconds = Int(interval) % 60
            
            if hours > 0 {
                timeRemaining = String(format: "%dh %02dm %02ds remaining", hours, minutes, seconds)
            } else if minutes > 0 {
                timeRemaining = String(format: "%dm %02ds remaining", minutes, seconds)
            } else {
                timeRemaining = String(format: "%ds remaining", seconds)
            }
        }
    }
}
