import Foundation
import GoogleMobileAds
import UIKit
import SwiftUI

class InterstitialAdManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    // Singleton instance
    static let shared = InterstitialAdManager()
    
    // Published property to notify views when ad state changes
    @Published var isAdReady = false
    
    // The interstitial ad object
    private var interstitialAd: GADInterstitialAd?
    
    // Track tab changes to show ads after every N changes
    private var tabChangeCount = 0
    private let tabChangesBeforeAd = 3 // Show ad after every 3 tab changes
    
    // Track if an ad is currently being loaded to prevent multiple simultaneous loads
    private var isLoading = false
    
    private override init() {
        super.init()
        loadInterstitialAd()
    }
    
    func loadInterstitialAd() {
        guard !isLoading else { return }
        isLoading = true
        
        // Get the ad unit ID from AdUnitIDs
        let adUnitID = AdUnitIDs.getInterstitialAdID(for: .transition)
        print("Loading interstitial ad with ad unit ID: \(adUnitID)")
        
        // Create the ad request
        let request = GADRequest()
        
        // Load the ad
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.isAdReady = false
                print("Interstitial ad failed to load with error: \(error.localizedDescription)")
                
                // Retry loading after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    self.loadInterstitialAd()
                }
                return
            }
            
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.isLoading = false
            self.isAdReady = true
            print("Interstitial ad loaded successfully")
        }
    }
    
    func showInterstitialAd(from viewController: UIViewController) -> Bool {
        // Increment tab change counter
        tabChangeCount += 1
        
        // Only show ad after every N tab changes
        if tabChangeCount < tabChangesBeforeAd {
            print("Not showing ad: tab change count is \(tabChangeCount)/\(tabChangesBeforeAd)")
            return false
        }
        
        // Reset counter when we're about to show an ad
        tabChangeCount = 0
        
        // Check if ad is loaded
        guard let interstitialAd = interstitialAd else {
            print("Interstitial ad not ready to be shown")
            if !isLoading {
                loadInterstitialAd()
            }
            return false
        }
        
        // Show the ad
        print("Showing interstitial ad")
        interstitialAd.present(fromRootViewController: viewController)
        isAdReady = false
        return true
    }
    
    // MARK: - GADFullScreenContentDelegate methods
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad impression logged")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Interstitial ad failed to present with error: \(error.localizedDescription)")
        loadInterstitialAd()
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad will present")
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad will dismiss")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad did dismiss")
        
        // Load the next ad
        loadInterstitialAd()
    }
}

// SwiftUI View extension to show interstitial ads
extension View {
    func showInterstitialAd() -> some View {
        self.modifier(InterstitialAdModifier())
    }
}

// SwiftUI modifier to handle interstitial ad presentation
struct InterstitialAdModifier: ViewModifier {
    @StateObject private var adManager = InterstitialAdManager.shared
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Find the UIViewController to present the ad
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    adManager.showInterstitialAd(from: rootViewController)
                }
            }
    }
}
