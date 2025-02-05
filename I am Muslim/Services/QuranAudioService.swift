import Foundation
import AVFoundation
import MediaPlayer

class QuranAudioService: ObservableObject {
    static let shared = QuranAudioService()
    private let baseURL = "https://api.alquran.cloud/v1"
    private var audioPlayer: AVPlayer?
    private var timeObserver: Any?
    private var playerItem: AVPlayerItem?
    
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var currentSurah: QuranSurah?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var allSurahs: [QuranSurah] = []
    
    private init() {
        setupAudioSession()
        configureRemoteCommandCenter()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func configureRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.togglePlayPause()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.togglePlayPause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.playNextSurah()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.playPreviousSurah()
            return .success
        }
    }
    
    func fetchSurahs() async throws -> [QuranSurah] {
        let url = URL(string: "\(baseURL)/surah")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(QuranResponse<[SurahResponse]>.self, from: data)
        
        let surahs = response.data.map { surah in
            QuranSurah(
                number: surah.number,
                name: surah.englishName,
                arabicName: surah.name,
                verses: surah.numberOfAyahs,
                duration: 0
            )
        }
        
        // Store surahs for next/previous functionality
        self.allSurahs = surahs
        return surahs
    }
    
    func playAudio(for surah: QuranSurah) {
        // Stop current playback
        stopAudio()
        
        // Set loading state and current surah immediately
        isLoading = true
        isPlaying = true
        errorMessage = nil
        currentSurah = surah
        
        // Construct the audio URL
        let audioURLString = "https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/\(surah.number).mp3"
        guard let url = URL(string: audioURLString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            isPlaying = false
            return
        }
        
        // Create player item and observe its status
        playerItem = AVPlayerItem(url: url)
        
        // Create new player and start loading
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        // Set initial playback rate
        audioPlayer?.rate = 1.0
        
        // Observe player item status
        let statusObserver = playerItem?.observe(\.status) { [weak self] item, _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    // Start playing as soon as it's ready
                    self.isLoading = false
                    self.duration = item.duration.seconds
                    self.audioPlayer?.play()
                    
                case .failed:
                    self.isLoading = false
                    self.isPlaying = false
                    self.errorMessage = "Failed to load audio"
                    
                default:
                    break
                }
            }
        }
        
        // Add time observer for progress tracking
        addTimeObserver()
        
        // Observe when audio finishes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        // Start loading and playing immediately
        audioPlayer?.play()
        
        updateNowPlayingInfo(title: surah.name, artist: "Quran Recitation")
    }
    
    private func addTimeObserver() {
        // Remove existing observer if any
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        // Add new observer with more frequent updates
        timeObserver = audioPlayer?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self,
                  let duration = self.audioPlayer?.currentItem?.duration.seconds,
                  duration.isFinite
            else { return }
            
            self.currentTime = time.seconds
            self.progress = time.seconds / duration
            
            // Update duration if not set
            if self.duration == 0 {
                self.duration = duration
            }
            
            self.updateNowPlayingInfo(title: self.currentSurah?.name ?? "", artist: "Quran Recitation")
        }
    }
    
    private func updateNowPlayingInfo(title: String, artist: String) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer?.currentItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer?.currentTime().seconds
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    func togglePlayPause() {
        guard let player = audioPlayer else {
            // If no audio is loaded and we have a current surah, play it
            if let currentSurah = currentSurah {
                playAudio(for: currentSurah)
            }
            return
        }
        
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
        
        updateNowPlayingInfo(title: currentSurah?.name ?? "", artist: "Quran Recitation")
    }
    
    func stopAudio() {
        audioPlayer?.pause()
        audioPlayer = nil
        playerItem = nil
        isPlaying = false
        progress = 0
        currentTime = 0
        duration = 0
        
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    func seekTo(_ time: Double) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        audioPlayer?.seek(to: targetTime) { [weak self] finished in
            if finished {
                self?.currentTime = time
                if let duration = self?.duration {
                    self?.progress = time / duration
                }
            }
        }
        
        updateNowPlayingInfo(title: currentSurah?.name ?? "", artist: "Quran Recitation")
    }
    
    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async { [weak self] in
            self?.stopAudio()
        }
    }
    
    func playNextSurah() {
        guard let currentSurah = currentSurah,
              let currentIndex = allSurahs.firstIndex(where: { $0.number == currentSurah.number }),
              currentIndex + 1 < allSurahs.count else {
            return
        }
        
        let nextSurah = allSurahs[currentIndex + 1]
        playAudio(for: nextSurah)
    }
    
    func playPreviousSurah() {
        guard let currentSurah = currentSurah,
              let currentIndex = allSurahs.firstIndex(where: { $0.number == currentSurah.number }),
              currentIndex > 0 else {
            return
        }
        
        let previousSurah = allSurahs[currentIndex - 1]
        playAudio(for: previousSurah)
    }
}

// API Response Models
struct QuranResponse<T: Codable>: Codable {
    let code: Int
    let status: String
    let data: T
}

struct SurahResponse: Codable {
    let number: Int
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let numberOfAyahs: Int
    let revelationType: String
}