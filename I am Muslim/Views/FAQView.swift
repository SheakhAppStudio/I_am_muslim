import SwiftUI

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQView: View {
    let faqs = [
        FAQItem(
            question: "How accurate are the prayer times?",
            answer: "Our prayer times are calculated using precise astronomical data and geographical location. We use trusted calculation methods approved by Islamic scholars. You can also customize the calculation method in settings to match your local mosque or preference."
        ),
        FAQItem(
            question: "How does the Qibla finder work?",
            answer: "The Qibla finder uses your device's compass and location to determine the direction of the Kaaba in Mecca. For best results, calibrate your device's compass by moving it in a figure-8 pattern and ensure you're away from magnetic interference."
        ),
        FAQItem(
            question: "Can I read the Quran offline?",
            answer: "Yes! The Holy Quran is available offline once downloaded. You can access all surahs, verses, and translations without an internet connection. Audio recitations require an internet connection for streaming."
        ),
        FAQItem(
            question: "How do I set up prayer notifications?",
            answer: "1. Go to Settings\n2. Enable 'Prayer Notifications'\n3. Allow notifications when prompted\n4. You'll receive timely alerts before each prayer time\n\nYou can customize notification settings in your device's Settings app."
        ),
        FAQItem(
            question: "How do I find nearby mosques?",
            answer: "Our mosque finder uses your current location to show nearby mosques. Simply:\n1. Allow location access when prompted\n2. Tap on the Mosques feature\n3. View mosques on the map or as a list\n4. Tap any mosque for directions and prayer times"
        ),
        FAQItem(
            question: "What is included in the Ramadan features?",
            answer: "The Ramadan timetable feature provides accurate prayer times specifically for Ramadan, including:\n- Fajr and Suhoor end time\n- Maghrib and Iftar time\n- All five daily prayers\n- Customizable calculation methods\n- Local mosque time adjustments"
        ),
        FAQItem(
            question: "How can I contribute or report issues?",
            answer: "We welcome your feedback! You can:\n1. Rate us on the App Store\n2. Email us at sheakhappstudio@icloud.com\n3. Report issues through the app's Support section\n4. Share the app with family and friends"
        ),
        FAQItem(
            question: "Is my data private?",
            answer: "Yes! We take your privacy seriously. We only collect essential data for app functionality (like location for prayer times and mosque finding). No personal data is shared with third parties. Read our Privacy Policy for more details."
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Frequently Asked Questions")
                    .font(.system(.title, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                ForEach(faqs) { faq in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(faq.question)
                            .font(.system(.headline, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundColor(IslamicTheme.accentColor)
                        
                        Text(faq.answer)
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
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
    }
}

#Preview {
    NavigationView {
        FAQView()
    }
}
