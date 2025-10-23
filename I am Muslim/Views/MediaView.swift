import SwiftUI
import AVKit

class MediaViewModel: NSObject, ObservableObject {
    @Published var selectedLiveStream: LiveStreamItem?
    @Published var selectedRadioStation: RadioStation?
    @Published var player: AVPlayer?
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedTab = 0 // 0 for Live Streams, 1 for Radio
    @Published var showLanguageSelector = false
    @Published var isPlaying = false
    
    private var timeObserver: Any?
    
    override init() {
        super.init()
        setupNotifications()
    }
    
    deinit {
        removeNotifications()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleInterruption),
                                             name: AVAudioSession.interruptionNotification,
                                             object: nil)
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleRouteChange),
                                             name: AVAudioSession.routeChangeNotification,
                                             object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            DispatchQueue.main.async {
                self.isPlaying = false
            }
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                player?.play()
                DispatchQueue.main.async {
                    self.isPlaying = true
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            DispatchQueue.main.async {
                self.isPlaying = false
            }
            player?.pause()
        default:
            break
        }
    }
    
    func handleStreamSelection(_ stream: LiveStreamItem) {
        print("🎬 Selected stream: \(stream.title)")
        
        selectedLiveStream = stream
        selectedRadioStation = nil
        
        guard let url = URL(string: stream.streamUrl) else {
            showError = true
            errorMessage = "Invalid stream URL"
            return
        }
        
        cleanupPlayer()
        setupNewPlayer(with: url)
    }
    
    func handleRadioSelection(_ station: RadioStation) {
        print("📻 Selected radio: \(station.name)")
        
        selectedRadioStation = station
        selectedLiveStream = nil
        
        guard let url = URL(string: station.url) else {
            showError = true
            errorMessage = "Invalid radio URL"
            return
        }
        
        cleanupPlayer()
        setupNewPlayer(with: url)
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    func cleanupPlayer() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player = nil
        isPlaying = false
    }
    
    private func setupNewPlayer(with url: URL) {
        print("▶️ Creating new player for URL: \(url)")
        let newPlayer = AVPlayer(url: url)
        
        // Add periodic time observer to update isPlaying state
        timeObserver = newPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.isPlaying = newPlayer.timeControlStatus == .playing
        }
        
        newPlayer.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
        player = newPlayer
        newPlayer.play()
        isPlaying = true
        print("✅ Player setup complete")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status",
           let item = object as? AVPlayerItem {
            DispatchQueue.main.async {
                switch item.status {
                case .failed:
                    print("❌ Player failed: \(String(describing: item.error))")
                    self.showError = true
                    self.errorMessage = "Failed to load stream: \(item.error?.localizedDescription ?? "Unknown error")"
                    self.isPlaying = false
                case .readyToPlay:
                    print("✅ Player ready to play")
                    self.isPlaying = true
                case .unknown:
                    print("⚠️ Player status unknown")
                @unknown default:
                    break
                }
            }
        }
    }
}

struct MediaView: View {
    @ObservedObject private var mediaService = MediaService.shared
    @StateObject private var viewModel = MediaViewModel()
    
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
                        Text("Islamic Media")
                            .font(.system(.title2, design: .serif))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        
                        Spacer()
                        
                        Button(action: { viewModel.showLanguageSelector.toggle() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "globe")
                                    .font(.system(size: 16))
                                Text("Language")
                                    .font(.system(.subheadline, design: .serif))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    
                    // Main Content
                    VStack(spacing: 0) {
                        // Header with Media Type Selector
                        VStack(spacing: 12) {
                            Picker("Media Type", selection: $viewModel.selectedTab) {
                                Text("Live Streams").tag(0)
                                Text("Radio").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                        }
                        
                        // Fixed Players Section
                        Group {
                            if viewModel.selectedTab == 0 {
                                // Live Stream Player (Fixed)
                                selectedStreamPlayer
                                    .padding(.horizontal)
                            } else {
                                // Radio Player (Fixed)
                                selectedRadioPlayer
                                    .padding(.horizontal)
                            }
                        }
                        
                        ScrollView {
                            // Native Banner Ad at the top of the scroll view
                            NativeBannerAdView(viewType: .media)
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            
                            if viewModel.selectedTab == 0 {
                                // Live Stream Buttons
                                VStack(alignment: .leading) {
                                    Text("Available Streams")
                                        .font(.system(.headline, design: .serif))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal)
                                    
                                    liveStreamButtons
                                }
                            } else {
                                // Radio Stations List
                                VStack(alignment: .leading) {
                                    Text("Available Stations")
                                        .font(.system(.headline, design: .serif))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal)
                                    
                                    radioStationsList
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showLanguageSelector) {
            LanguageSelectorView(selectedLanguage: mediaService.selectedLanguage) { language in
                mediaService.setLanguage(language)
                viewModel.showLanguageSelector = false
            }
        }
        .onDisappear {
            viewModel.cleanupPlayer()
        }
    }
    
    private var liveStreamButtons: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 200))], spacing: 20) {
            ForEach(mediaService.liveStreams) { stream in
                Button(action: { viewModel.handleStreamSelection(stream) }) {
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)), Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.2, alpha: 1))]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            VStack(spacing: 10) {
                                if let logoUrl = URL(string: stream.tvgLogo) {
                                    AsyncImage(url: logoUrl) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 80, height: 80)
                                        case .failure(_):
                                            Image(systemName: "play.tv.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white)
                                        case .empty:
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        @unknown default:
                                            Image(systemName: "play.tv.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white)
                                        }
                                    }
                                } else {
                                    Image(systemName: "play.tv.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                                
                                Text(stream.title)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 20)
                            }
                        }
                        .frame(height: 160)
                    }
                }
            }
        }
        .padding()
    }
    
    private var radioStationsList: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity))], spacing: 16) {
            ForEach(mediaService.radioStations) { station in
                Button(action: { viewModel.handleRadioSelection(station) }) {
                    HStack(alignment: .center, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)), Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.2, alpha: 1))]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            
                            Image(systemName: "radio.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(station.name)
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                            
                            if let language = station.language {
                                Text(language)
                                    .font(.system(.subheadline, design: .serif))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(IslamicTheme.accentColor)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.05))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    )
                }
            }
        }
        .padding()
    }
    
    private var selectedStreamPlayer: some View {
        Group {
            if let stream = viewModel.selectedLiveStream,
               let player = viewModel.player {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Now Playing")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Button(action: { 
                            viewModel.player?.pause()
                            viewModel.isPlaying = false
                            viewModel.cleanupPlayer()
                            viewModel.selectedLiveStream = nil 
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                    
                    CustomVideoPlayer(player: player)
                        .frame(height: 200)
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private var selectedRadioPlayer: some View {
        Group {
            if let station = viewModel.selectedRadioStation,
               let player = viewModel.player {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Now Playing")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        // Radio Icon
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)), Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.2, alpha: 1))]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "radio.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        
                        // Station Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(station.name)
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            if let language = station.language {
                                Text(language)
                                    .font(.system(.subheadline, design: .serif))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        // Controls
                        HStack(spacing: 16) {
                            Button(action: viewModel.togglePlayPause) {
                                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(IslamicTheme.accentColor)
                            }
                            
                            Button(action: { 
                                viewModel.player?.pause()
                                viewModel.isPlaying = false
                                viewModel.cleanupPlayer()
                                viewModel.selectedRadioStation = nil 
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)), Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.2, alpha: 1))]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                }
            }
        }
    }
    
    // Custom button style for scale animation
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}

// MARK: - Custom Video Player
struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
