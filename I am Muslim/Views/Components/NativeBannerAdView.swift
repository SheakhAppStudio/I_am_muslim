import SwiftUI
import GoogleMobileAds
import UIKit

// A reusable banner ad component that can be used in any view
struct NativeBannerAdView: View {
    @StateObject private var viewModel: PrayerAdViewModel
    @State private var hasAttemptedLoad = false
    
    init(viewType: AdViewType = .other) {
        _viewModel = StateObject(wrappedValue: PrayerAdViewModel(viewType: viewType))
    }
    
    var body: some View {
        VStack {
            if viewModel.isAdLoaded {
                PrayerViewNativeBannerAdView(viewModel: viewModel)
                    .frame(height: 50)
                    .padding(.horizontal)
            } else {
                // Optional: Show a placeholder when ad is not loaded
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 0)
            }
        }
        .onAppear {
            // Only attempt to load the ad once when the view appears
            if !hasAttemptedLoad {
                hasAttemptedLoad = true
                viewModel.loadAd()
            }
        }
    }
}
