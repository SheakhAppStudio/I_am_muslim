import SwiftUI

// Helper view for TextField placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct QuranView: View {
    @StateObject private var audioService = QuranAudioService.shared
    @State private var searchText = ""
    @State private var showFullPlayer = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // Use AppStorage to cache surahs
    @AppStorage("cachedSurahs") private var cachedSurahsData: Data = Data()
    @State private var surahs: [QuranSurah] = []
    
    var filteredSurahs: [QuranSurah] {
        if searchText.isEmpty {
            return surahs
        }
        return surahs.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.arabicName.contains(searchText) ||
            String($0.number).contains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with Islamic Pattern
                IslamicTheme.primaryGradient
                    .ignoresSafeArea()
                    .overlay(
                        IslamicPatternView(color: .white, opacity: 0.05)
                            .ignoresSafeArea()
                    )
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    HStack {
                        Text("Holy Quran")
                            .font(.system(.title2, design: .serif))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if audioService.isPlaying {
                            Button(action: { showFullPlayer = true }) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(IslamicTheme.accentColor)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Spacer()
                    } else if let error = errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text(error)
                                .font(.system(.body, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task { await loadSurahs() }
                            }
                            .foregroundColor(IslamicTheme.accentColor)
                        }
                        .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 25) {
                                // Search Bar
                                HStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(IslamicTheme.accentColor)
                                    
                                    TextField("", text: $searchText)
                                        .placeholder(when: searchText.isEmpty) {
                                            Text("Search Surah")
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        .font(.system(.body, design: .serif))
                                        .foregroundColor(.white)
                                        .tint(.white)
                                    
                                    if !searchText.isEmpty {
                                        Button(action: { searchText = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: IslamicTheme.smallCornerRadius)
                                        .fill(Color.white.opacity(0.15))
                                )
                                .padding(.horizontal)
                                
                                // All Surahs List
                                VStack(spacing: 20) {
                                    Text("All Surahs")
                                        .font(.system(.title3, design: .serif))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    LazyVStack(spacing: 15) {
                                        ForEach(filteredSurahs) { surah in
                                            SurahListItem(
                                                number: surah.number,
                                                name: surah.name,
                                                arabicName: surah.arabicName,
                                                verses: surah.verses
                                            )
                                            .onTapGesture {
                                                audioService.playAudio(for: surah)
                                                showFullPlayer = true
                                            }
                                            
                                            if surah.number != filteredSurahs.last?.number {
                                                Divider()
                                                    .background(Color.white.opacity(0.1))
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: IslamicTheme.cornerRadius)
                                            .fill(IslamicTheme.secondaryGradient)
                                            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
                                    )
                                }
                                .padding(.horizontal)
                                
                                // Add padding at the bottom if mini player is showing
                                if audioService.currentSurah != nil {
                                    Color.clear.frame(height: 80)
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        // Mini Player
                        if let surah = audioService.currentSurah {
                            QuranMiniPlayer(
                                surah: surah,
                                isPlaying: $audioService.isPlaying,
                                progress: $audioService.progress,
                                onTap: { showFullPlayer = true }
                            )
                        }
                    }
                }
                .navigationBarHidden(true)
                
                // Error Alert
                if let errorMessage = audioService.errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(10)
                            .padding()
                            .transition(.move(edge: .bottom))
                    }
                    .zIndex(1)
                }
            }
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            if let surah = audioService.currentSurah {
                QuranFullPlayer(
                    surah: surah,
                    isPlaying: $audioService.isPlaying,
                    progress: $audioService.progress
                )
            }
        }
        .task {
            await loadSurahs()
        }
    }
    
    private func loadSurahs() async {
        // First try to load from cache
        if !cachedSurahsData.isEmpty {
            do {
                let decoder = JSONDecoder()
                surahs = try decoder.decode([QuranSurah].self, from: cachedSurahsData)
                isLoading = false
                return
            } catch {
                print("Failed to decode cached surahs: \(error)")
            }
        }
        
        // If cache is empty or invalid, load from network
        isLoading = true
        errorMessage = nil
        
        do {
            surahs = try await QuranAudioService.shared.fetchSurahs()
            
            // Cache the loaded surahs
            do {
                let encoder = JSONEncoder()
                cachedSurahsData = try encoder.encode(surahs)
            } catch {
                print("Failed to cache surahs: \(error)")
            }
        } catch {
            errorMessage = "Failed to load surahs. Please check your internet connection and try again."
        }
        
        isLoading = false
    }


struct SurahListItem: View {
    let number: Int
    let name: String
    let arabicName: String
    let verses: Int
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                // Surah Number Circle
                ZStack {
                    Circle()
                        .fill(IslamicTheme.accentColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text("\(number)")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(IslamicTheme.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(arabicName)
                        .font(.system(.title3, design: .serif))
                        .foregroundColor(IslamicTheme.textColor)
                    
                    Text(name)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(IslamicTheme.subtleText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "text.book.closed")
                            .font(.caption)
                        Text("\(verses) verses")
                            .font(.system(.caption, design: .serif))
                    }
                    .foregroundColor(IslamicTheme.subtleText)
                }
                
                Spacer()
                
                // Play Button
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(IslamicTheme.accentColor.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: IslamicTheme.smallCornerRadius)
                .fill(IslamicTheme.cardBackground)
        )
    }
}

}
