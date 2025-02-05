import SwiftUI
import UserNotifications
import StoreKit

struct SettingsView: View {
    @State private var notificationsEnabled = false
    @State private var showingNotificationAlert = false
    
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
                
                // Navigation Bar Background
                VStack {
                    IslamicTheme.primaryGradient
                        .frame(height: 100)
                        .ignoresSafeArea()
                    Spacer()
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Preferences")
                                .font(.system(.title2, design: .serif))
                                .foregroundColor(.white)
                            
                            // Prayer Notifications Toggle
                            Button(action: {
                                toggleNotifications()
                            }) {
                                HStack {
                                    Image(systemName: "bell")
                                        .font(.title3)
                                    Text("Prayer Notifications")
                                        .font(.system(.body, design: .serif))
                                    Spacer()
                                    Image(systemName: notificationsEnabled ? "checkmark" : "")
                                        .foregroundColor(IslamicTheme.accentColor)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .alert("Enable Notifications", isPresented: $showingNotificationAlert) {
                                Button("Open Settings", role: .none) {
                                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsUrl)
                                    }
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("Please enable notifications in Settings to receive prayer time alerts.")
                            }
                        }
                        .padding(.horizontal)
                        
                        // Share & Rate Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Share & Rate")
                                .font(.system(.title2, design: .serif))
                                .foregroundColor(.white)
                            
                            Button(action: shareApp) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title3)
                                    Text("Share App")
                                        .font(.system(.body, design: .serif))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            Button(action: rateApp) {
                                HStack {
                                    Image(systemName: "star")
                                        .font(.title3)
                                    Text("Rate App")
                                        .font(.system(.body, design: .serif))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Support Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Support")
                                .font(.system(.title2, design: .serif))
                                .foregroundColor(.white)
                            
                            NavigationLink(destination: HelpAndSupportView()) {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.title3)
                                    Text("Help & Support")
                                        .font(.system(.body, design: .serif))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            

                        }
                        .padding(.horizontal)
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("About")
                                .font(.system(.title2, design: .serif))
                                .foregroundColor(.white)
                            
                            NavigationLink(destination: AboutView()) {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .font(.title3)
                                    Text("About I am Muslim")
                                        .font(.system(.body, design: .serif))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            NavigationLink(destination: PrivacyPolicyView()) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .font(.title3)
                                    Text("Privacy Policy")
                                        .font(.system(.body, design: .serif))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            HStack {
                                Image(systemName: "number")
                                    .font(.title3)
                                Text("Version")
                                    .font(.system(.body, design: .serif))
                                Spacer()
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(IslamicTheme.accentColor)
                        
                        Text("Settings")
                            .font(.system(.title3, design: .serif))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 8)
                }
            }
            .background(.clear)
        }
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    private func rateApp() {
        // First try to open the App Store review page directly
        if let reviewURL = URL(string: "https://apps.apple.com/gb/app/i-am-muslim/id6741376864?action=write-review") {
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        } else {
            // Fallback to in-app review prompt
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
    private func shareApp() {
        let message = """
        Assalamualaikum! 🌙

        I wanted to share with you this amazing Islamic app that helps me stay connected with my faith. "I am Muslim" provides accurate prayer times, Qibla direction, complete Quran, and Islamic calendar.

        Follow This Link: https://apps.apple.com/gb/app/i-am-muslim/id6741376864

        JazakAllah Khair 🤲
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func contactUs() {
        if let url = URL(string: "mailto:sheakhappstudio@icloud.com?subject=I%20am%20Muslim%20App%20Support&body=Assalamualaikum,") {
            UIApplication.shared.open(url)
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func toggleNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // Request permission
                    NotificationManager.shared.setup()
                    self.notificationsEnabled = true
                case .authorized:
                    if self.notificationsEnabled {
                        // Turn off notifications
                        NotificationManager.shared.removeAllPendingNotifications()
                        self.notificationsEnabled = false
                    } else {
                        // Turn on notifications
                        NotificationManager.shared.setup()
                        self.notificationsEnabled = true
                    }
                case .denied:
                    // Show alert to go to settings
                    self.showingNotificationAlert = true
                default:
                    break
                }
            }
        }
    }
}

struct IslamicSettingsRow: View {
    let title: String
    let icon: String
    var showChevron: Bool = true
    
    var body: some View {
        HStack {
            Label {
                Text(title)
                    .font(.system(.body, design: .serif))
            } icon: {
                Image(systemName: icon)
            }
            .foregroundColor(.white)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: IslamicTheme.smallCornerRadius)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct SupportView: View {
    var body: some View {
        ZStack {
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
            
            ScrollView {
                VStack(spacing: 20) {
                    IslamicDisclosureGroup(title: "Prayer Times") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Prayer times are calculated using reliable astronomical formulas.")
                                .foregroundColor(.white)
                            Text("You can adjust the calculation method in Prayer Settings.")
                                .foregroundColor(.white)
                        }
                    }
                    
                    IslamicDisclosureGroup(title: "Qibla Direction") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("The Qibla compass uses your device's built-in sensors.")
                                .foregroundColor(.white)
                            Text("For best results, calibrate your compass by moving your device in a figure-8 pattern.")
                                .foregroundColor(.white)
                        }
                    }
                    
                    IslamicDisclosureGroup(title: "Notifications") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Enable notifications to receive prayer time reminders.")
                                .foregroundColor(.white)
                            Text("You can customize notification settings in your device's Settings app.")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Help & Support")
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.white)
            }
        }
        .background(IslamicTheme.primaryGradient.ignoresSafeArea())
    }
}

struct IslamicDisclosureGroup<Content: View>: View {
    let title: String
    let content: Content
    @State private var isExpanded = false
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(title)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            
            if isExpanded {
                content
                    .padding(.leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: IslamicTheme.smallCornerRadius)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct AboutView: View {
    var body: some View {
        ZStack {
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
            
            ScrollView {
                VStack(spacing: 35) {
                    // App Icon and Title
                    VStack(spacing: 15) {
                        
                        Text("I am Muslim")
                            .font(.system(.title, design: .serif))
                            .foregroundColor(.white)
                    }
                    
                    // About Section
                    VStack(spacing: 15) {
                        Text("About The App")
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.white)
                        
                        Text("I am Muslim is your daily companion for Islamic practices, designed to help Muslims worldwide stay connected with their faith. Our app provides accurate prayer times, Qibla direction, complete Quran with translations, and an Islamic calendar.")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Key Features
                    VStack(spacing: 25) {
                        Text("Key Features")
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 10) {
                            FeatureCard(icon: "clock.fill", title: "Prayer Times")
                            FeatureCard(icon: "location.north.circle.fill", title: "Qibla Finder")
                            FeatureCard(icon: "book.fill", title: "Holy Quran")
                            FeatureCard(icon: "map.fill", title: "Mosques")
                            FeatureCard(icon: "moon.stars.fill", title: "Ramadan")
                            FeatureCard(icon: "bell.fill", title: "Notifications")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Developer Section
                    VStack(spacing: 15) {
                        Text("Developer")
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "hammer.fill")
                                .foregroundColor(IslamicTheme.accentColor)
                            Text("Sheakh App Studio")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 5)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("About")
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.white)
            }
        }
        .background(IslamicTheme.primaryGradient.ignoresSafeArea())
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(IslamicTheme.accentColor)
            
            Text(title)
                .font(.system(.body, design: .serif))
                .foregroundColor(.white)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ContactView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ZStack {
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
            
            VStack(spacing: 20) {
                Text("Contact Us")
                    .font(.system(.title2, design: .serif))
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text("We'd love to hear from you! If you have any questions, suggestions, or need assistance, please don't hesitate to reach out.")
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    if let url = URL(string: "mailto:sheakhappstudio@icloud.com?subject=I%20am%20Muslim%20App%20Support&body=Assalamualaikum,") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Email Us")
                    }
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("Privacy Policy")
                        .font(.system(.title, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Last updated: February 1, 2025")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(alignment: .leading, spacing: 20) {
                        PrivacySection(
                            title: "Our Commitment",
                            content: "At Sheakh App Studio, we are committed to protecting your privacy and ensuring you have a trustworthy experience with our app."
                        )
                        
                        PrivacySection(
                            title: "Information We Collect",
                            content: "We collect minimal data necessary for app functionality:\n• Location data: Used solely for calculating accurate prayer times and Qibla direction\n• Device settings: To save your app preferences\n\nAll data processing happens directly on your device."
                        )
                        
                        PrivacySection(
                            title: "How We Use Your Information",
                            content: "• Prayer Times: Location data is used to calculate accurate prayer times\n• Qibla Direction: Location is used to determine the direction of Kaaba\n• Preferences: To save your app settings"
                        )
                        
                        PrivacySection(
                            title: "Data Storage",
                            content: "All app data is stored locally on your device. We do not collect, store, or share any personal information on external servers."
                        )
                        
                        PrivacySection(
                            title: "Notifications",
                            content: "If enabled, we send local notifications for prayer times. These notifications are processed entirely on your device and can be managed in your device settings."
                        )
                        
                        PrivacySection(
                            title: "Third-Party Services",
                            content: "We don't share any data with third parties. The app functions independently on your device."
                        )
                        
                        PrivacySection(
                            title: "Contact Us",
                            content: "If you have any questions about our privacy policy, please contact us at sheakhappstudio@icloud.com"
                        )
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Privacy Policy")
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.white)
            }
        }
    }
}

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundColor(.white)
            
            Text(content)
                .font(.system(.body, design: .serif))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: IslamicTheme.smallCornerRadius)
                .fill(Color.white.opacity(0.1))
        )
    }
}

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
