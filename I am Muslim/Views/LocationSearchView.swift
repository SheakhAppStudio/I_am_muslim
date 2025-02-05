import SwiftUI
import CoreLocation

struct LocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchService = LocationSearchService()
    @State private var searchText = ""
    @State private var showMosqueMenu = false
    let viewModel: PrayerTimesViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBarView
                currentLocationButton
                mosqueSelectionButton
                Divider()
                searchResultsList
            }
            .navigationBarTitle("Select Location", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
        .onChange(of: searchText) { newValue in
            Task {
                await searchService.searchLocations(query: newValue)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search location...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    searchService.cancelSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var currentLocationButton: some View {
        Button(action: {
            viewModel.useCurrentLocation()
            dismiss()
        }) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(ThemeColors.primary)
                Text("Use Current Location")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    private var mosqueSelectionButton: some View {
        Button(action: {
            showMosqueMenu = true
        }) {
            HStack {
                Image(systemName: "house.fill")
                    .foregroundColor(ThemeColors.primary)
                Text("Select Mosque")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showMosqueMenu) {
            MosqueSelectionView(viewModel: viewModel, showMosqueMenu: $showMosqueMenu, dismiss: dismiss)
        }
    }
    
    private var searchResultsList: some View {
        List {
            ForEach(searchService.searchResults) { result in
                Button(action: {
                    viewModel.setCustomLocation(
                        coordinate: result.coordinate,
                        name: result.title
                    )
                    dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(result.title)
                            .foregroundColor(.primary)
                        Text(result.subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Mosque Selection View
struct MosqueSelectionView: View {
    let viewModel: PrayerTimesViewModel
    @Binding var showMosqueMenu: Bool
    let dismiss: DismissAction
    
    @State private var loadingMessage = ""
    @State private var showLoadingToast = false
    private let loadingMessages = [
        "Connecting to mosque server...",
        "Fetching today's prayer times...",
        "The server is responding slowly...",
        "Still trying to get prayer times...",
        "Please wait, the server is taking longer than usual...",
        "We're still working on getting your prayer times...",
        "Don't worry, we'll keep trying for a bit longer...",
        "The mosque server is experiencing delays..."
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        buryParkMosqueButton
                        // Add more mosque buttons here
                    }
                    .padding(.top, 16)
                }
                
                // Loading Toast
                if showLoadingToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                            Text(loadingMessage)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.black.opacity(0.7))
                        )
                        .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarTitle("Select Mosque", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showMosqueMenu = false
                }
                .foregroundColor(.white)
            )
            .background(
                VStack(spacing: 0) {
                    Color.black.opacity(0.2)
                        .frame(height: 50)
                    IslamicTheme.primaryGradient
                }
                .ignoresSafeArea()
            )
        }
    }
    
    private var buryParkMosqueButton: some View {
        Button(action: {
            fetchBuryParkPrayerTimes()
        }) {
            HStack(spacing: 16) {
                Image(systemName: "building.columns.fill")
                    .font(.title2)
                    .foregroundColor(ThemeColors.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bury Park Mosque")
                        .font(.headline)
                        .foregroundColor(ThemeColors.text)
                    Text("Luton, UK")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.text.opacity(0.7))
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(ThemeColors.primary)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(ThemeColors.text.opacity(0.5))
                        .font(.caption)
                }
            }
            .padding()
            .background(ThemeColors.cardBackground)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .disabled(isLoading)
        .alert("Unable to Load Prayer Times", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    private func fetchBuryParkPrayerTimes() {
        Task {
            do {
                await MainActor.run { 
                    isLoading = true
                    showLoadingToast = true
                    loadingMessage = loadingMessages[0]
                }
                
                // Start loading message updates
                let messageUpdateTask = Task {
                    var messageIndex = 1
                    while !Task.isCancelled {
                        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                        if messageIndex < loadingMessages.count {
                            await MainActor.run {
                                withAnimation {
                                    loadingMessage = loadingMessages[messageIndex]
                                }
                            }
                            messageIndex += 1
                        }
                    }
                }
                
                // First try to fetch prayer times
                print("🔄 Fetching Bury Park Mosque prayer times...")
                let prayers = try await MosquePrayerService.shared.fetchBuryParkPrayerTimes(forceRefresh: true)
                print("✅ Successfully fetched \(prayers.count) prayer times")
                
                // Cancel loading messages
                messageUpdateTask.cancel()
                
                // Update UI on main thread
                await MainActor.run {
                    // Set prayer times first
                    viewModel.setPrayerTimes(prayers, isMosqueTimes: true, mosqueId: "bury_park_masjid")
                    print("✅ Set prayer times in view model")
                    
                    // Then update location
                    viewModel.setCustomLocation(
                        coordinate: CLLocationCoordinate2D(
                            latitude: 51.8789,
                            longitude: -0.4174
                        ),
                        name: "Bury Park Mosque, Luton, UK"
                    )
                    print("✅ Updated mosque location")
                    
                    // Finally close the menu and dismiss
                    withAnimation {
                        showLoadingToast = false
                    }
                    showMosqueMenu = false
                    dismiss()
                    print("✅ UI updated successfully")
                }
            } catch let error as MosquePrayerError {
                print("❌ Mosque prayer error: \(error.localizedDescription)")
                await MainActor.run {
                    withAnimation {
                        showLoadingToast = false
                    }
                    errorMessage = error.localizedDescription
                }
            } catch {
                print("❌ Unexpected error: \(error)")
                await MainActor.run {
                    withAnimation {
                        showLoadingToast = false
                    }
                    errorMessage = "Unable to fetch mosque prayer times. Please check your internet connection and try again."
                }
            }
            
            // Always reset loading state on main thread
            await MainActor.run { 
                isLoading = false
            }
        }
    }
}
