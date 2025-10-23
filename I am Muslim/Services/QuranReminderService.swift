import Foundation
import UserNotifications

class QuranReminderService {
    static let shared = QuranReminderService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    
    private let reminderKey = "quranReminderEnabled"
    private let notificationId = "daily-quran-reminder"
    private let hasCompletedFirstLaunchKey = "hasCompletedFirstLaunch"
    
    private init() {
        print("📱 Initializing QuranReminderService")
        // Check if this is the first launch
        if !defaults.bool(forKey: hasCompletedFirstLaunchKey) {
            print("🆕 First launch detected - enabling Quran reminder by default")
            // Enable Quran reminder by default on first launch
            defaults.set(true, forKey: reminderKey)
            defaults.set(true, forKey: hasCompletedFirstLaunchKey)
            
            // Schedule the reminder
            scheduleReminder()
        } else {
            print("✅ Previous launch detected - checking reminder status")
            // Check if reminder should be active
            if isReminderEnabled {
                verifyAndUpdateReminder()
            }
        }
    }
    
    var isReminderEnabled: Bool {
        get { defaults.bool(forKey: reminderKey) }
        set { 
            defaults.set(newValue, forKey: reminderKey)
            print("🔄 Quran reminder \(newValue ? "enabled" : "disabled")")
        }
    }
    
    // Random encouraging messages
    private let messages = [
        "Time to connect with the Quran ❤️",
        "Let's read some Quran together 📖",
        "Take a moment with Allah's words 🤲",
        "Your daily dose of spiritual peace ✨",
        "Ready for some Quran time? 🌙",
        "Let's strengthen our connection with Allah 💫"
    ]
    
    private func verifyAndUpdateReminder() {
        print("🔍 Verifying existing Quran reminder")
        notificationCenter.getPendingNotificationRequests { requests in
            let hasReminder = requests.contains { $0.identifier == self.notificationId }
            if !hasReminder {
                print("⚠️ Quran reminder not found - rescheduling")
                DispatchQueue.main.async {
                    self.scheduleReminder()
                }
            } else {
                print("✅ Quran reminder is active")
            }
        }
    }
    
    func scheduleReminder() {
        print("📅 Scheduling Quran reminder for 10:30 PM")
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = messages.randomElement() ?? "Time for Quran"
        content.body = "Take a moment to read or listen to the Quran"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "QURAN_REMINDER"
        
        // Create 10:30 PM trigger
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 30
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: notificationId,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error scheduling Quran reminder: \(error.localizedDescription)")
            } else {
                print("✅ Quran reminder scheduled successfully")
                // Verify the next trigger date
                if let trigger = trigger.nextTriggerDate() {
                    print("📅 Next reminder scheduled for: \(trigger)")
                }
            }
        }
        
        // Set up notification categories for actions
        let openAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open App",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: "QURAN_REMINDER",
            actions: [openAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        notificationCenter.setNotificationCategories([category])
    }
    
    func cancelReminder() {
        print("🚫 Cancelling Quran reminder")
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
    
    func toggleReminder(enabled: Bool) {
        print("🔄 Toggling Quran reminder: \(enabled ? "ON" : "OFF")")
        isReminderEnabled = enabled
        if enabled {
            scheduleReminder()
        } else {
            cancelReminder()
        }
    }
    
    func checkReminderStatus() {
        notificationCenter.getPendingNotificationRequests { requests in
            print("\n=== Quran Reminder Status ===")
            print("🔔 Reminder enabled in settings: \(self.isReminderEnabled)")
            
            let reminderRequests = requests.filter { $0.identifier == self.notificationId }
            print("📝 Active reminder requests: \(reminderRequests.count)")
            
            for request in reminderRequests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let next = trigger.nextTriggerDate() {
                    print("⏰ Next reminder: \(next)")
                }
            }
            print("===========================\n")
        }
    }
}
