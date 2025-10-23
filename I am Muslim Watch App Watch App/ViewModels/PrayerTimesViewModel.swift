//
//  PrayerTimesViewModel.swift
//  I am Muslim Watch App Watch App
//
//  Created by Cascade AI on 25/04/2025.
//

import Foundation
import CoreLocation
import SwiftUI

@MainActor
class PrayerTimesViewModel: ObservableObject {
    static let shared = PrayerTimesViewModel()
    
    private let locationManager = LocationManager.shared
    private let prayerAPIService = PrayerAPIService.shared
    
    @Published private(set) var prayers: [PrayerTime] = []
    @Published private(set) var nextPrayer: PrayerTime?
    @Published var locationName: String = "Loading..."
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var refreshTask: Task<Void, Never>?
    private var updateTimer: Timer?
    
    private init() {
        setupLocationUpdates()
        setupTimer()
    }
    
    private func setupLocationUpdates() {
        // Set up location update handler
        locationManager.onLocationNameUpdate = { [weak self] name in
            Task { @MainActor in
                self?.locationName = name
            }
        }
        
        // Set up location update handler to trigger prayer time refresh
        locationManager.onLocationUpdate = { [weak self] location in
            guard let self = self else { return }
            Task {
                await self.refreshPrayerTimes(forceRefresh: true)
            }
        }
        
        // Request location permissions if needed
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestLocationPermission()
        }
        
        // Start location updates
        locationManager.startUpdatingLocation()
        
        // Set initial location name
        self.locationName = locationManager.locationName
    }
    
    private func setupTimer() {
        // Update next prayer every minute
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateNextPrayer()
        }
    }
    
    func refreshPrayerTimes(forceRefresh: Bool = false) async {
        // Cancel any existing task
        refreshTask?.cancel()
        
        refreshTask = Task {
            do {
                isLoading = true
                errorMessage = nil
                
                guard let location = locationManager.location else {
                    isLoading = false
                    errorMessage = "Location not available"
                    return
                }
                
                let fetchedPrayers = try await prayerAPIService.fetchPrayerTimes(for: location, forceRefresh: forceRefresh)
                
                // Update on main actor
                await MainActor.run {
                    self.prayers = fetchedPrayers
                    self.updateNextPrayer()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to fetch prayer times: \(error.localizedDescription)"
                    print("Error fetching prayer times: \(error)")
                }
            }
        }
    }
    
    func updateNextPrayer() {
        let now = Date()
        
        // Find the next prayer that hasn't occurred yet
        if let upcoming = prayers.first(where: { $0.time > now }) {
            nextPrayer = upcoming
        } else {
            // If all prayers for today have passed, show the first prayer (for tomorrow)
            nextPrayer = prayers.first
        }
    }
    
    deinit {
        updateTimer?.invalidate()
        refreshTask?.cancel()
    }
}
