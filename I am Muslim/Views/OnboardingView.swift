import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "بِسْمِ ٱللّٰهِ",
            subtitle: "Welcome to I am Muslim",
            description: "Your comprehensive companion for daily Islamic practices",
            imageName: "AppIcon",
            isSystemImage: false,
            gradientColors: [Color(hex: "4B956F"), Color(hex: "2D5A43")]
        ),
        OnboardingPage(
            title: "Prayer Times",
            arabicTitle: "مواقيت الصلاة",
            description: "Get accurate prayer times based on your location with beautiful Adhan notifications",
            imageName: "clock.fill",
            isSystemImage: true,
            gradientColors: [Color(hex: "C3934B"), Color(hex: "8B672D")]
        ),
        OnboardingPage(
            title: "Qibla Direction",
            arabicTitle: "اتجاه القبلة",
            description: "Find the direction of the Kaaba easily with our precise Qibla compass",
            imageName: "location.north.circle.fill",
            isSystemImage: true,
            gradientColors: [Color(hex: "8B4B95"), Color(hex: "5D2D64")]
        ),
        OnboardingPage(
            title: "Islamic Calendar",
            arabicTitle: "التقويم الهجري",
            description: "Keep track of important Islamic dates and events throughout the year",
            imageName: "calendar",
            isSystemImage: true,
            gradientColors: [Color(hex: "956F4B"), Color(hex: "5A432D")]
        )
    ]
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index], isLastPage: index == pages.count - 1) {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Custom Page Control
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? .white : .white.opacity(0.3))
                            .frame(width: currentPage == index ? 20 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let completion: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: page.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Islamic Pattern Overlay
            IslamicPatternView(color: .white, opacity: 0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon with animation
                Group {
                    if page.isSystemImage {
                        Image(systemName: page.imageName)
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                    } else {
                        Image(page.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.white.opacity(0.1), radius: 20, x: 0, y: 0)
                            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 5)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white.opacity(0.1))
                                    .blur(radius: 20)
                                    .offset(y: 10)
                            )
                    }
                }
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .opacity(isAnimating ? 1.0 : 0.5)
                .padding(.bottom, 20)
                
                // Titles
                if let arabicTitle = page.arabicTitle {
                    Text(arabicTitle)
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                
                Text(page.title)
                    .font(.system(.title, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                
                // Description
                Text(page.description)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                
                Spacer()
                
                // Get Started Button (only on last page)
                if isLastPage {
                    Button(action: completion) {
                        Text("Get Started")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(page.gradientColors[0])
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            )
                            .padding(.horizontal, 32)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

struct OnboardingPage {
    let title: String
    let arabicTitle: String?
    let subtitle: String?
    let description: String
    let imageName: String
    let isSystemImage: Bool
    let gradientColors: [Color]
    
    init(
        title: String,
        arabicTitle: String? = nil,
        subtitle: String? = nil,
        description: String,
        imageName: String,
        isSystemImage: Bool,
        gradientColors: [Color]
    ) {
        self.title = title
        self.arabicTitle = arabicTitle
        self.subtitle = subtitle
        self.description = description
        self.imageName = imageName
        self.isSystemImage = isSystemImage
        self.gradientColors = gradientColors
    }
}

#Preview {
    OnboardingView()
}
