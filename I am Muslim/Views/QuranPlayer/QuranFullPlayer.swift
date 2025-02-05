import SwiftUI

struct QuranFullPlayer: View {
    let surah: QuranSurah
    @Binding var isPlaying: Bool
    @Binding var progress: Double
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioService = QuranAudioService.shared
    
    var body: some View {
        ZStack {
            // Background with Islamic Pattern
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
            
            // Content
            VStack(spacing: 30) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("NOW PLAYING")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("Mishary Rashid Alafasy")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Surah Info
                VStack(spacing: 16) {
                    // Surah Number Circle
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .fill(IslamicTheme.accentColor.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Text("\(surah.number)")
                            .font(.system(size: 40, weight: .medium, design: .serif))
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                    
                    VStack(spacing: 8) {
                        Text(surah.arabicName)
                            .font(.system(.title, design: .serif))
                            .foregroundColor(.white)
                        
                        Text(surah.name)
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(surah.verses) Verses")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Progress Section
                VStack(spacing: 12) {
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(IslamicTheme.accentColor)
                                .frame(width: geometry.size.width * audioService.progress, height: 4)
                                .cornerRadius(2)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let percentage = min(max(0, value.location.x / geometry.size.width), 1)
                                    audioService.progress = percentage
                                }
                                .onEnded { value in
                                    let percentage = min(max(0, value.location.x / geometry.size.width), 1)
                                    audioService.seekTo(percentage * audioService.duration)
                                }
                        )
                    }
                    .frame(height: 4)
                    
                    // Time Labels
                    HStack {
                        Text(formatTime(audioService.currentTime))
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        Text(formatTime(audioService.duration))
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal)
                
                // Controls
                HStack(spacing: 40) {
                    Button(action: { audioService.playPreviousSurah() }) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { audioService.togglePlayPause() }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { audioService.playNextSurah() }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 30)
                
                // Bottom Controls
                HStack(spacing: 60) {
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Image(systemName: "quote.bubble")
                                .font(.title3)
                            Text("Translation")
                                .font(.system(.caption, design: .serif))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Image(systemName: "text.justify")
                                .font(.title3)
                            Text("Verses")
                                .font(.system(.caption, design: .serif))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Image(systemName: "bookmark")
                                .font(.title3)
                            Text("Bookmark")
                                .font(.system(.caption, design: .serif))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.bottom, 30)
            }
            .padding(.vertical)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
