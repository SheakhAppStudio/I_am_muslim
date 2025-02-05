import SwiftUI
import CoreLocation

struct PrayerLocationHeader: View {
    let locationName: String
    let onLocationTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onLocationTap) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(IslamicTheme.accentColor)
                    Text(locationName)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: IslamicTheme.smallCornerRadius)
                        .fill(Color.white.opacity(0.1))
                )
            }
            
            HStack {
                Text(Date(), style: .date)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct PrayerNextCard: View {
    let prayer: PrayerTime
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Next Prayer")
                .font(.system(.title3, design: .serif))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            IslamicPrayerCard(prayer: prayer, isNext: true, isLarge: true)
        }
        .padding(.horizontal)
    }
}

struct PrayerTimesHeader: View {
    var body: some View {
        Text("Today's Prayers")
            .font(.system(.title3, design: .serif))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PrayerTimesContent: View {
    let prayers: [PrayerTime]
    let nextPrayerId: UUID?
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(prayers) { prayer in
                IslamicPrayerCard(
                    prayer: prayer,
                    isNext: prayer.id == nextPrayerId
                )
                
                if prayer.id != prayers.last?.id {
                    Divider()
                        .background(Color.white.opacity(0.1))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: IslamicTheme.cornerRadius)
                .fill(IslamicTheme.secondaryGradient)
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
        )
    }
}

struct PrayerTimesList: View {
    let prayers: [PrayerTime]
    let nextPrayerId: UUID?
    
    var body: some View {
        VStack(spacing: 20) {
            PrayerTimesHeader()
            PrayerTimesContent(prayers: prayers, nextPrayerId: nextPrayerId)
        }
        .padding(.horizontal)
    }
}

struct PrayerView: View {
    @StateObject private var viewModel = PrayerTimesViewModel.shared
    @StateObject private var settingsManager = PrayerSettingsManager.shared
    @State private var showLocationSearch = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with Islamic Pattern
                IslamicTheme.primaryGradient
                    .ignoresSafeArea()
                    .overlay(
                        IslamicPatternView(color: .white, opacity: 0.05)
                            .ignoresSafeArea()
                    )
                
                // Main Content
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    HStack {
                        Text("Prayer Times")
                            .font(.system(.title2, design: .serif))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                Task {
                                    await viewModel.refreshPrayerTimes(forceRefresh: true)
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title2)
                                    .foregroundColor(IslamicTheme.accentColor)
                                    .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                                    .animation(
                                        viewModel.isLoading ?
                                            .linear(duration: 1).repeatForever(autoreverses: false) :
                                            .linear(duration: 0.3),
                                        value: viewModel.isLoading
                                    )
                            }
                            .disabled(viewModel.isLoading)
                            
                            NavigationLink {
                                PrayerSettingsView()
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(IslamicTheme.accentColor)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    
                    ScrollView(showsIndicators: true) {
                        VStack(spacing: 25) {
                            PrayerLocationHeader(
                                locationName: viewModel.locationName,
                                onLocationTap: { showLocationSearch = true }
                            )
                            
                            if let nextPrayer = viewModel.nextPrayer {
                                PrayerNextCard(prayer: nextPrayer)
                            }
                            
                            PrayerTimesList(
                                prayers: viewModel.prayers,
                                nextPrayerId: viewModel.nextPrayer?.id
                            )
                        }
                        .padding(.vertical)
                    }
                    .navigationBarHidden(true)
                }
            }
            .refreshable {
                print("Pull-to-refresh triggered")
                // First update location if using current location
                if !LocationManager.shared.isUsingCustomLocation {
                    LocationManager.shared.startUpdatingLocation()
                }
                // Then refresh prayer times
                await viewModel.refreshPrayerTimes(forceRefresh: true)
            }
            .sheet(isPresented: $showLocationSearch) {
                LocationSearchView(viewModel: viewModel)
            }
            .alert(viewModel.errorMessage ?? "", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK", role: .cancel) {}
            }
            .onReceive(NotificationCenter.default.publisher(for: .prayerSettingsChanged)) { _ in
                print("PrayerView: Settings changed notification received")
                Task {
                    print("PrayerView: Refreshing prayer times due to settings change")
                    await viewModel.refreshPrayerTimes(forceRefresh: true)
                }
            }
            .task {
                // Check if we have location permission
                let locationManager = LocationManager.shared
                print("Checking location permission")
                
                // Only refresh if we have no prayers or it's a new day
                if viewModel.prayers.isEmpty || !Calendar.current.isDateInToday(viewModel.lastFetchDate ?? Date.distantPast) {
                    print("Prayer view: Refreshing prayer times - no data or new day")
                    if locationManager.location == nil && !locationManager.isUsingCustomLocation {
                        // Only request location if using current location
                        locationManager.startUpdatingLocation()
                    }
                    await viewModel.refreshPrayerTimes()
                } else {
                    print("Prayer view: Using cached prayer times")
                }
            }
            .onAppear {
                PrayerSettingsManager.shared.onSettingsChanged = {
                    Task {
                        await viewModel.refreshPrayerTimes()
                    }
                }
            }
        }
    }
    
    struct PrayerView_Previews: PreviewProvider {
        static var previews: some View {
            PrayerView()
        }
    }
}
