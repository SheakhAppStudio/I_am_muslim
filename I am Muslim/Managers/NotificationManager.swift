import UserNotifications
import Foundation
import BackgroundTasks

class NotificationManager {
    static let shared = NotificationManager()
    private let backgroundTaskIdentifier = "com.iammuslim.prayertimes.refresh"
    private var isRegistered = false
    
    private init() {
        // Don't automatically request authorization or register background tasks
        // This should be done explicitly when needed
    }
    
    func setup() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if granted {
                print("Notification permission granted")
                // Remove any existing notifications and reschedule on main thread
                DispatchQueue.main.async {
                    self?.removeAllPendingNotifications()
                }
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Public method for AppDelegate to schedule background tasks
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        // Schedule the refresh for 15 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Successfully scheduled app refresh")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func schedulePrayerNotifications(for prayerTimes: [PrayerTime], usingMosque: Bool = false, mosqueName: String? = nil) {
        print("\n=== Starting Prayer Notification Scheduling ===")
        
        // First remove all existing notifications
        print("Removing all existing notifications...")
        removeAllPendingNotifications()
        
        let center = UNUserNotificationCenter.current()
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        for prayerTime in prayerTimes {
            // Only schedule if the prayer time is in the future
            if prayerTime.time <= now {
                print("Skipping notification for \(prayerTime.name): Time has already passed")
                continue
            }
            
            let content = UNMutableNotificationContent()
            let timeString = dateFormatter.string(from: prayerTime.time)
            
            if usingMosque, let mosqueName = mosqueName {
                // Mosque-specific notification
                if let jamahTime = prayerTime.jamahTime {
                    let jamahTimeString = dateFormatter.string(from: jamahTime)
                    content.title = "Assalamualaikum"
                    content.body = "It's time for \(prayerTime.name) at \(timeString) at \(mosqueName), Jamah at \(jamahTimeString)"
                } else {
                    content.title = "Assalamualaikum"
                    content.body = "It's time for \(prayerTime.name) at \(timeString) at \(mosqueName)"
                }
            } else {
                // Regular prayer time notification
                content.title = "Assalamualaikum"
                content.body = "It's time for \(prayerTime.name) at \(timeString)"
            }
            
            content.sound = .default
            
            // Create a calendar-based trigger
            let components = Calendar.current.dateComponents([.hour, .minute], from: prayerTime.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Create the request
            let request = UNNotificationRequest(
                identifier: "prayer-\(prayerTime.name)-\(prayerTime.time.timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )
            
            // Schedule the notification
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification for \(prayerTime.name): \(error)")
                } else {
                    print("Successfully scheduled notification for \(prayerTime.name) at \(prayerTime.time)")
                }
            }
        }
    }
    
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}
