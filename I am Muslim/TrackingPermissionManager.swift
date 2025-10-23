import Foundation
import AppTrackingTransparency
import AdSupport
import UIKit

class TrackingPermissionManager {
    static let shared = TrackingPermissionManager()
    
    private init() {}
    
    func requestTrackingPermission(completion: @escaping (Bool) -> Void) {
        // The best practice is to delay the permission request until the app is fully active
        // This ensures the permission dialog appears properly on top of your app
        
        // Wait for the app to be in active state
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.showTrackingPermissionRequest(completion: completion)
            // Remove observer after first activation
            NotificationCenter.default.removeObserver(self!, name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    
    private func showTrackingPermissionRequest(completion: @escaping (Bool) -> Void) {
        // Add a slight delay to ensure the app is fully visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if #available(iOS 14, *) {
                // Check current status first
                let currentStatus = ATTrackingManager.trackingAuthorizationStatus
                
                // Only request if status is not determined yet
                if currentStatus == .notDetermined {
                    print("Requesting tracking authorization...")
                    ATTrackingManager.requestTrackingAuthorization { status in
                        DispatchQueue.main.async {
                            let authorized = status == .authorized
                            print("Tracking authorization status: \(status.rawValue), authorized: \(authorized)")
                            completion(authorized)
                        }
                    }
                } else {
                    // Already determined, just return current status
                    let authorized = currentStatus == .authorized
                    print("Tracking already determined: \(currentStatus.rawValue), authorized: \(authorized)")
                    completion(authorized)
                }
            } else {
                // For iOS < 14, tracking is enabled by default
                print("iOS version < 14, tracking enabled by default")
                completion(true)
            }
        }
    }
}
