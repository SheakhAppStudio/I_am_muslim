import Foundation
import SwiftUI

class MediaService: ObservableObject {
    static let shared = MediaService()
    
    private let cache = NSCache<NSString, NSData>()
    private let userDefaults = UserDefaults.standard
    private let jsonURL = "https://raw.githubusercontent.com/SheakhAppStudio/I_am_muslim/main/i_am_muslim.json"
    private let radioBaseURL = "https://mp3quran.net/api/v3/radios"
    
    @Published var liveStreams: [LiveStreamItem] = []
    @Published var radioStations: [RadioStation] = []
    @Published var isLoadingRadio = false
    @Published var radioError: String?
    @Published var selectedLanguage: RadioLanguage = .arabic {
        didSet {
            Task {
                await fetchRadioStations()
            }
        }
    }
    
    private init() {
        setupCache()
        // Load saved language preference
        if let savedLanguage = userDefaults.string(forKey: "RadioLanguage"),
           let language = RadioLanguage(rawValue: savedLanguage) {
            selectedLanguage = language
        }
        
        Task {
            await fetchLiveStreams()
            await fetchRadioStations()
        }
    }
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    // MARK: - Live Streams
    func fetchLiveStreams() async {
        do {
            print("🔄 Fetching live streams from: \(jsonURL)")
            guard let url = URL(string: jsonURL) else {
                print("❌ Invalid JSON URL")
                return
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ Invalid response")
                return
            }
            
            let decoder = JSONDecoder()
            let config = try decoder.decode(LiveStreamConfig.self, from: data)
            
            DispatchQueue.main.async {
                self.liveStreams = config.customURL
                print("✅ Loaded \(self.liveStreams.count) live streams")
            }
        } catch {
            print("❌ Error fetching live streams: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Radio Stations
    func fetchRadioStations() async {
        DispatchQueue.main.async {
            self.isLoadingRadio = true
            self.radioError = nil
        }
        
        do {
            let urlString = "\(radioBaseURL)?language=\(selectedLanguage.rawValue)"
            print("🔄 Fetching radio stations from: \(urlString)")
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("📻 Radio API Response Status: \(httpResponse.statusCode)")
            
            let responseString = String(data: data, encoding: .utf8)
            print("📻 Radio API Response: \(responseString ?? "No data")")
            
            let decoder = JSONDecoder()
            let radioResponse = try decoder.decode(RadioResponse.self, from: data)
            
            // Filter out stations with empty or invalid URLs
            let validStations = radioResponse.radios.filter { !$0.url.isEmpty }
            
            DispatchQueue.main.async {
                self.radioStations = validStations
                self.isLoadingRadio = false
                print("✅ Loaded \(self.radioStations.count) radio stations")
            }
        } catch {
            print("❌ Error fetching radio stations: \(error)")
            DispatchQueue.main.async {
                self.radioError = error.localizedDescription
                self.isLoadingRadio = false
            }
        }
    }
    
    func setLanguage(_ language: RadioLanguage) {
        selectedLanguage = language
        userDefaults.set(language.rawValue, forKey: "RadioLanguage")
    }
}
