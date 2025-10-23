import Foundation

/// A struct containing all ad unit IDs used in the app
struct AdUnitIDs {
    // MARK: - AdMob App ID
    
    /// AdMob application ID
    static let appID = "ca-app-pub-9884279835867851~4616784890"
    
    // MARK: - Banner Ads
    
    /// Banner ad unit ID for the Home view
    static let homeBannerAdID = "ca-app-pub-9884279835867851/4859531318"
    
    /// Banner ad unit ID for the Media view
    static let mediaBannerAdID = "ca-app-pub-9884279835867851/4859531318"
    
    /// Banner ad unit ID for the Settings view
    static let settingsBannerAdID = "ca-app-pub-9884279835867851/4859531318"
    
    /// Banner ad unit ID for the Prayer view
    static let prayerBannerAdID = "ca-app-pub-9884279835867851/4859531318"
    
    /// Banner ad unit ID for the Quran view
    static let quranBannerAdID = "ca-app-pub-9884279835867851/4859531318"
    
    /// Banner ad unit ID for the Mosque view
    static let mosqueBannerAdID = "ca-app-pub-9884279835867851/4859531318"
    
    /// Default banner ad unit ID
    static let defaultBannerAdID = "ca-app-pub-9884279835867851/4859531318"
    
    // MARK: - Interstitial Ads
    
    /// Interstitial ad unit ID for app transitions
    static let transitionInterstitialAdID = "ca-app-pub-9884279835867851/8742940197"
    
    /// Interstitial ad unit ID for Quran reading completion
    static let quranCompletionInterstitialAdID = "ca-app-pub-9884279835867851/8742940197"
    
    // MARK: - Rewarded Ads
    
    /// Rewarded ad unit ID for premium content
    static let premiumContentRewardedAdID = "ca-app-pub-9884279835867851/8742940197"
    
    /// Returns the appropriate ad ID based on the view type
    static func getBannerAdID(for viewType: AdViewType) -> String {
        switch viewType {
        case .home:
            return homeBannerAdID
        case .media:
            return mediaBannerAdID
        case .settings:
            return settingsBannerAdID
        case .prayer:
            return prayerBannerAdID
        case .quran:
            return quranBannerAdID
        case .mosque:
            return mosqueBannerAdID
        case .other:
            return defaultBannerAdID
        }
    }
    
    /// Returns the appropriate interstitial ad ID based on the interstitial type
    static func getInterstitialAdID(for type: InterstitialAdType) -> String {
        switch type {
        case .transition:
            return transitionInterstitialAdID
        case .quranCompletion:
            return quranCompletionInterstitialAdID
        }
    }
    
    /// Returns the appropriate rewarded ad ID based on the rewarded type
    static func getRewardedAdID(for type: RewardedAdType) -> String {
        switch type {
        case .premiumContent:
            return premiumContentRewardedAdID
        }
    }
}

/// Enum representing different view types for banner ad placement
enum AdViewType {
    case home
    case media
    case settings
    case prayer
    case quran
    case mosque
    case other
}

/// Enum representing different interstitial ad types
enum InterstitialAdType {
    case transition
    case quranCompletion
}

/// Enum representing different rewarded ad types
enum RewardedAdType {
    case premiumContent
}
