import Foundation

class UpdateChecker: ObservableObject {
    static let shared = UpdateChecker()
    
    @Published var isUpdateAvailable = false
    @Published var latestVersion: String?
    @Published var updateURL: String?
    
    private let appId = "6741376864" // Your App Store ID
    
    private init() {}
    
    func checkForUpdates() async {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let url = URL(string: "https://itunes.apple.com/lookup?id=\(appId)") else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONDecoder().decode(AppStoreResponse.self, from: data)
            
            if let appStoreVersion = json.results.first?.version {
                DispatchQueue.main.async {
                    self.latestVersion = appStoreVersion
                    self.updateURL = "https://apps.apple.com/app/id\(self.appId)"
                    self.isUpdateAvailable = self.compareVersions(appStoreVersion, isGreaterThan: currentVersion)
                }
            }
        } catch {
            print("Failed to check for updates: \(error)")
        }
    }
    
    private func compareVersions(_ version1: String, isGreaterThan version2: String) -> Bool {
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(v1Components.count, v2Components.count)
        let v1Padded = v1Components + Array(repeating: 0, count: maxLength - v1Components.count)
        let v2Padded = v2Components + Array(repeating: 0, count: maxLength - v2Components.count)
        
        for i in 0..<maxLength {
            if v1Padded[i] > v2Padded[i] {
                return true
            } else if v1Padded[i] < v2Padded[i] {
                return false
            }
        }
        return false
    }
}

// Response models for App Store API
struct AppStoreResponse: Codable {
    let results: [AppStoreResult]
}

struct AppStoreResult: Codable {
    let version: String
}
