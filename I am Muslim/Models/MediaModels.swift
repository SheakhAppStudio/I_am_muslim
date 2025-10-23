import Foundation

// MARK: - Live Stream Models
struct LiveStream: Identifiable {
    let id: String
    let title: String
    let streamURL: String
    let thumbnailURL: String
    
    static let makkahLive = LiveStream(
        id: "makkah",
        title: "Makkah Live",
        streamURL: "https://turnerlive.warnermediacdn.com/hls/live/586495/cnngo/cnn_slate/VIDEO_0_3564000.m3u",
        thumbnailURL: "makkah_thumbnail"
    )
    
    static let madinahLive = LiveStream(
        id: "madinah",
        title: "Madinah Live",
        streamURL: "YOUR_MADINAH_STREAM_URL",
        thumbnailURL: "madinah_thumbnail"
    )
}

// MARK: - Live Stream Config
struct LiveStreamConfig: Codable {
    let showDefaultURL: Bool
    let showCustomURL: Bool
    let customURL: [LiveStreamItem]
    
    enum CodingKeys: String, CodingKey {
        case showDefaultURL
        case showCustomURL
        case customURL
    }
}

struct LiveStreamItem: Identifiable, Codable {
    let title: String
    let tvgId: String
    let tvgLogo: String
    let streamUrl: String
    
    var id: String { tvgId }
    
    enum CodingKeys: String, CodingKey {
        case title
        case tvgId
        case tvgLogo
        case streamUrl
    }
}

// MARK: - Media Category
enum MediaCategory: String, CaseIterable {
    case live = "Live"
    case videos = "Videos"
    case playlists = "Playlists"
    
    var icon: String {
        switch self {
        case .live:
            return "dot.radiowaves.left.and.right"
        case .videos:
            return "play.rectangle.fill"
        case .playlists:
            return "list.bullet.rectangle.fill"
        }
    }
}
