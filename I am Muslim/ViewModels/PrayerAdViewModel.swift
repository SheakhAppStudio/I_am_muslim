import Foundation
import GoogleMobileAds

class PrayerAdViewModel: NSObject, ObservableObject, GADBannerViewDelegate {
    @Published var bannerView: GADBannerView?
    @Published var isAdLoaded = false
    @Published var adError: String?
    
    private let adUnitID: String
    
    init(viewType: AdViewType = .other) {
        self.adUnitID = AdUnitIDs.getBannerAdID(for: viewType)
        super.init()
    }
    
    func loadAd() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Log the ad loading
            print("Loading banner ad with ad unit ID: \(self.adUnitID)")
            
            // Create a new banner view
            let bannerView = GADBannerView(adSize: GADAdSizeBanner)
            bannerView.adUnitID = self.adUnitID
            bannerView.delegate = self
            
            // Get the root view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                bannerView.rootViewController = rootViewController
            }
            
            self.bannerView = bannerView
            
            // Load the ad
            let request = GADRequest()
            bannerView.load(request)
        }
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        DispatchQueue.main.async {
            self.isAdLoaded = true
            self.adError = nil
            
            // Log successful ad load
            print("Banner ad loaded successfully")
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        DispatchQueue.main.async {
            self.isAdLoaded = false
            self.adError = error.localizedDescription
            print("Banner ad failed to load with error: \(error.localizedDescription)")
        }
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("Banner ad impression is being captured.")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("Banner ad will present screen.")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("Banner ad will dismiss screen.")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("Banner ad did dismiss screen.")
    }
}
