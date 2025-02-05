import SwiftUI

struct QuranMiniPlayer: View {
    let surah: QuranSurah
    @Binding var isPlaying: Bool
    @Binding var progress: Double
    var onTap: () -> Void
    @StateObject private var audioService = QuranAudioService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(IslamicTheme.accentColor)
                        .frame(width: geometry.size.width * progress, height: 2)
                }
            }
            .frame(height: 2)
            
            // Player Content
            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Surah Number Circle
                    ZStack {
                        Circle()
                            .fill(IslamicTheme.accentColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Text("\(surah.number)")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                    
                    // Surah Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(surah.arabicName)
                            .font(.system(.body, design: .serif))
                            .foregroundColor(IslamicTheme.textColor)
                        
                        Text(surah.name)
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(IslamicTheme.subtleText)
                    }
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 20) {
                        Button(action: { audioService.playPreviousSurah() }) {
                            Image(systemName: "backward.fill")
                                .font(.title3)
                                .foregroundColor(IslamicTheme.textColor)
                        }
                        
                        Button(action: { audioService.togglePlayPause() }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title3)
                                .foregroundColor(IslamicTheme.textColor)
                        }
                        
                        Button(action: { audioService.playNextSurah() }) {
                            Image(systemName: "forward.fill")
                                .font(.title3)
                                .foregroundColor(IslamicTheme.textColor)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(IslamicTheme.cardBackground)
            }
        }
        .background(IslamicTheme.cardBackground)
    }
}
