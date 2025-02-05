import SwiftUI

struct HelpAndSupportView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // App Overview Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("About I am Muslim")
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("I am Muslim is your comprehensive Islamic companion app, designed to help you maintain your daily Islamic practices with ease and accuracy. Our app combines modern technology with Islamic traditions to provide you with essential tools for your spiritual journey.")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                
                // Key Features Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Key Features")
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    FeatureRow(icon: "clock.fill", title: "Prayer Times", description: "Accurate prayer times based on your location with customizable calculation methods")
                    
                    FeatureRow(icon: "location.fill", title: "Qibla Finder", description: "Precise Qibla direction using advanced compass technology")
                    
                    FeatureRow(icon: "book.fill", title: "Holy Quran", description: "Complete Quran with translations and audio recitations")
                    
                    FeatureRow(icon: "map.fill", title: "Mosque Finder", description: "Locate nearby mosques with prayer times and directions")
                    
                    FeatureRow(icon: "moon.stars.fill", title: "Ramadan Timetable", description: "Accurate Ramadan prayer times including Fajr/Suhoor and Maghrib/Iftar times(Coming Soon)")
                    
                    FeatureRow(icon: "bell.fill", title: "Notifications", description: "Customizable prayer time notifications to keep you on track")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                
                // Getting Started Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Getting Started")
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("1. Enable Location Services for accurate prayer times and Qibla direction")
                        .foregroundColor(.white)
                    Text("2. Allow notifications to receive prayer time alerts")
                        .foregroundColor(.white)
                    Text("3. Customize your prayer calculation method in settings")
                        .foregroundColor(.white)
                    Text("4. Download Quran content for offline access(Coming Soon)")
                        .foregroundColor(.white)
                    Text("5. Set up your preferred Adhan sound and notification style(Coming Soon)")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                
                // Support Options
                VStack(alignment: .leading, spacing: 15) {
                    Text("Need Help?")
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Button(action: { openEmail() }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Contact Support")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: FAQView()) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text("View FAQs")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .background(
            IslamicTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    IslamicPatternView(color: .white, opacity: 0.05)
                        .ignoresSafeArea()
                )
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Help & Support")
    }
    
    private func openEmail() {
        if let url = URL(string: "mailto:sheakhappstudio@icloud.com?subject=I%20am%20Muslim%20App%20Support&body=Assalamualaikum,") {
            UIApplication.shared.open(url)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(IslamicTheme.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
}

#Preview {
    NavigationView {
        HelpAndSupportView()
    }
}
