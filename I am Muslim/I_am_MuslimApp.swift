//
//  I_am_MuslimApp.swift
//  I am Muslim
//
//  Created by Sheakh Emon on 01/02/2025.
//

import SwiftUI
import BackgroundTasks

@main
struct I_am_MuslimApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Register background tasks before anything else
        registerBackgroundTasks()
        
        // Initialize other app components
        setupNotifications()
        
        return true
    }
    
    private func registerBackgroundTasks() {
        // Register background task for prayer time updates
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.iammuslim.prayertimes.refresh",
            using: nil
        ) { task in
            self.handlePrayerTimeRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handlePrayerTimeRefresh(task: BGAppRefreshTask) {
        // Create an operation that performs the background fetch
        let operation = BlockOperation {
            NotificationManager.shared.scheduleAppRefresh()
        }
        
        // When the operation completes, mark the background task as complete
        operation.completionBlock = {
            task.setTaskCompleted(success: true)
        }
        
        // If the background task expires, cancel the operation
        task.expirationHandler = {
            operation.cancel()
        }
        
        // Schedule the next background fetch
        let request = BGAppRefreshTaskRequest(identifier: "com.iammuslim.prayertimes.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Schedule for 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
        
        // Start the fetch operation
        OperationQueue.main.addOperation(operation)
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundTasks()
    }
    
    private func scheduleBackgroundTasks() {
        let request = BGAppRefreshTaskRequest(identifier: "com.iammuslim.prayertimes.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Schedule for 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
