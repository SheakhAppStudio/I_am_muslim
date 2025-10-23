import SwiftUI
import AVKit

struct RadioPlayerView: View {
    @ObservedObject var mediaService = MediaService.shared
    @State private var player: AVPlayer?
    @State private var currentStation: RadioStation?
    @State private var isPlaying = false
    @State private var showLanguageSelector = false
    
    var body: some View {
        VStack {
            // Header with Language Selection
            HStack {
                Text("Islamic Radio")
                    .font(.title)
                
                Spacer()
                
                Button(action: { showLanguageSelector = true }) {
                    HStack {
                        Text(mediaService.selectedLanguage.displayName)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.accentColor)
                    }
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            
            // Radio Stations List
            if mediaService.isLoadingRadio {
                ProgressView("Loading Radio Stations...")
            } else if let error = mediaService.radioError {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                    Button("Retry") {
                        Task {
                            await mediaService.fetchRadioStations()
                        }
                    }
                }
            } else if mediaService.radioStations.isEmpty {
                Text("No radio stations available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(mediaService.radioStations) { station in
                    RadioStationRow(station: station,
                                  isPlaying: isPlaying && currentStation?.id == station.id,
                                  onTap: { playStation(station) })
                }
            }
        }
        .sheet(isPresented: $showLanguageSelector) {
            LanguageSelectorView(selectedLanguage: mediaService.selectedLanguage) { language in
                mediaService.setLanguage(language)
                showLanguageSelector = false
            }
        }
    }
    
    private func playStation(_ station: RadioStation) {
        guard let url = URL(string: station.url) else { return }
        
        if currentStation?.id == station.id {
            // Toggle play/pause for current station
            if isPlaying {
                player?.pause()
            } else {
                player?.play()
            }
            isPlaying.toggle()
        } else {
            // Play new station
            player?.pause()
            let newPlayer = AVPlayer(url: url)
            player = newPlayer
            newPlayer.play()
            currentStation = station
            isPlaying = true
        }
    }
}

struct RadioStationRow: View {
    let station: RadioStation
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(station.name)
                        .font(.headline)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .padding(.vertical, 8)
        }
    }
}

struct LanguageSelectorView: View {
    let selectedLanguage: RadioLanguage
    let onSelect: (RadioLanguage) -> Void
    
    var body: some View {
        NavigationView {
            List(RadioLanguage.allCases) { language in
                Button(action: { onSelect(language) }) {
                    HStack {
                        Text(language.displayName)
                        Spacer()
                        if language == selectedLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RadioPlayerView()
}
