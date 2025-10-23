import SwiftUI
import GoogleMobileAds
import UIKit

struct PrayerViewNativeBannerAdView: UIViewRepresentable {
    @ObservedObject var viewModel: PrayerAdViewModel
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Remove any existing banner views
        uiView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add the banner view if it's loaded
        if let bannerView = viewModel.bannerView, viewModel.isAdLoaded {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            uiView.addSubview(bannerView)
            
            NSLayoutConstraint.activate([
                bannerView.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
                bannerView.topAnchor.constraint(equalTo: uiView.topAnchor),
                bannerView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor)
            ])
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: PrayerViewNativeBannerAdView
        
        init(_ parent: PrayerViewNativeBannerAdView) {
            self.parent = parent
        }
    }
}

// A wrapper view that handles the ad state
struct PrayerNativeBannerAdWrapper: View {
    @StateObject private var viewModel = PrayerAdViewModel(viewType: .prayer)
    @State private var hasAttemptedLoad = false
    
    var body: some View {
        VStack {
            if viewModel.isAdLoaded {
                PrayerViewNativeBannerAdView(viewModel: viewModel)
                    .frame(height: 70)
                    .padding(.horizontal)
            } else {
                // Show a placeholder or nothing when ad is not loaded
                EmptyView()
            }
        }
        .onAppear {
            if !hasAttemptedLoad {
                hasAttemptedLoad = true
                viewModel.loadAd()
            }
        }
    }
}
