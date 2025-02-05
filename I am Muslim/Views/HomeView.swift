import SwiftUI

struct HomeView: View {
    @StateObject private var prayerTimesViewModel = PrayerTimesViewModel.shared
    @StateObject private var updateChecker = UpdateChecker.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab: NavigationDestination?
    @State private var showUpdateAlert = false
    
    enum NavigationDestination {
        case qibla, mosques, calendar
    }
    
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
                
                if #available(iOS 15.0, *) {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Welcome Section
                            VStack(alignment: .leading, spacing: 8) {
                                if #available(iOS 15.0, *) {
                                    Text("السَّلامُ عَلَيْكُمْ")
                                        .font(.system(.title2, design: .serif))
                                        .foregroundColor(.white)
                                } else {
                                    Text("السَّلامُ عَلَيْكُمْ")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                
                                if #available(iOS 15.0, *) {
                                    Text(getGreeting())
                                        .font(.system(.title3, design: .serif))
                                        .foregroundColor(.white.opacity(0.9))
                                } else {
                                    Text(getGreeting())
                                        .font(.title3)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                if #available(iOS 15.0, *) {
                                    Text("May Allah bless your day")
                                        .font(.system(.headline, design: .serif))
                                        .foregroundColor(.white.opacity(0.8))
                                } else {
                                    Text("May Allah bless your day")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Next Prayer Card
                            if let nextPrayer = prayerTimesViewModel.nextPrayer {
                                NextPrayerCard(prayer: nextPrayer)
                                    .padding(.horizontal)
                            }
                            
                            // Quick Actions Grid
                            VStack(spacing: 14) {
                                Text("Quick Actions")
                                    .font(.system(.title3, design: .serif))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 14) {
                                    QuickActionButton(
                                        title: "Qibla",
                                        icon: "location.north.circle.fill",
                                        color: Color(hex: "4B956F"),
                                        action: { selectedTab = .qibla }
                                    )
                                    
                                    QuickActionButton(
                                        title: "Mosques",
                                        icon: "building.columns.circle.fill",
                                        color: Color(hex: "C3934B"),
                                        action: { selectedTab = .mosques }
                                    )
                                    
                                    QuickActionButton(
                                        title: "Calendar",
                                        icon: "calendar.circle.fill",
                                        color: Color(hex: "8B4B95"),
                                        action: { selectedTab = .calendar }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            // Daily Verse Card
                            DailyVerseCard()
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                        .padding(.vertical)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 25) {
                            // Welcome Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("السَّلامُ عَلَيْكُمْ")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Text(getGreeting())
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("May Allah bless your day")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Next Prayer Card
                            if let nextPrayer = prayerTimesViewModel.nextPrayer {
                                NextPrayerCard(prayer: nextPrayer)
                                    .padding(.horizontal)
                            }
                            
                            // Quick Actions Grid
                            VStack(spacing: 14) {
                                Text("Quick Actions")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 14) {
                                    QuickActionButton(
                                        title: "Qibla",
                                        icon: "location.north.circle.fill",
                                        color: Color(hex: "4B956F"),
                                        action: { selectedTab = .qibla }
                                    )
                                    
                                    QuickActionButton(
                                        title: "Mosques",
                                        icon: "building.columns.circle.fill",
                                        color: Color(hex: "C3934B"),
                                        action: { selectedTab = .mosques }
                                    )
                                    
                                    QuickActionButton(
                                        title: "Calendar",
                                        icon: "calendar.circle.fill",
                                        color: Color(hex: "8B4B95"),
                                        action: { selectedTab = .calendar }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            // Daily Verse Card
                            DailyVerseCard()
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .alert("Update Available", isPresented: $showUpdateAlert) {
                Button("Update Now") {
                    if let updateURL = updateChecker.updateURL,
                       let url = URL(string: updateURL) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Later", role: .cancel) {}
            } message: {
                Text("A new version (\(updateChecker.latestVersion ?? "")) is available. Update now to get the latest features and improvements.")
            }
            .task {
                // Check for updates when view appears
                await updateChecker.checkForUpdates()
                if updateChecker.isUpdateAvailable {
                    showUpdateAlert = true
                }
            }
            
            // Navigation links
            .background(
                NavigationLink(
                    destination: QiblaView(),
                    isActive: Binding(
                        get: { selectedTab == .qibla },
                        set: { if !$0 { selectedTab = nil } }
                    )
                ) { EmptyView() }
            )
            .background(
                NavigationLink(
                    destination: MosqueView(),
                    isActive: Binding(
                        get: { selectedTab == .mosques },
                        set: { if !$0 { selectedTab = nil } }
                    )
                ) { EmptyView() }
            )
            .background(
                NavigationLink(
                    destination: IslamicCalendarView(),
                    isActive: Binding(
                        get: { selectedTab == .calendar },
                        set: { if !$0 { selectedTab = nil } }
                    )
                ) { EmptyView() }
            )
        }
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<20: return "Good Evening"
        default: return "Good Night"
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(.subheadline, design: .serif))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

struct DailyVerseCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Daily Verse")
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "bookmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(IslamicTheme.accentColor)
            }
            
            Text("Indeed, Allah is with those who are patient.")
                .font(.system(.body, design: .serif))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineSpacing(6)
            
            Text("Surah Al-Baqarah, Verse 153")
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
