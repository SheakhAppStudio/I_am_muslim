import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.7
    @State private var opacity = 0.4
    @State private var rotationAngle = 0.0
    @State private var showText = false
    @State private var showWelcome = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if isActive {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        } else {
            ZStack {
                IslamicTheme.primaryGradient
                    .ignoresSafeArea()
                
                // Islamic Pattern Background
                IslamicPatternView(color: .white, opacity: 0.05)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Spacer()
                    
                    // Main Logo
                    ZStack {
                        // Outer Circle with Islamic Pattern
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(rotationAngle))
                        
                        // Inner Circle with Gradient
                        Circle()
                            .fill(IslamicTheme.accentColor.opacity(0.2))
                            .frame(width: 150, height: 150)
                        
                        // App Icon or Symbol
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    
                    // App Name and Bismillah with Animation
                    VStack(spacing: 15) {
                        Text("I am Muslim")
                            .font(.system(.title, design: .serif))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(showText ? 1 : 0)
                            .offset(y: showText ? 0 : 20)
                        
                        Text("بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ")
                            .font(.system(.title2, design: .serif))
                            .foregroundColor(.white)
                            .opacity(showText ? 1 : 0)
                            .offset(y: showText ? 0 : 20)
                        
                        Text("In the name of Allah, the Most Gracious, the Most Merciful")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .opacity(showText ? 1 : 0)
                            .offset(y: showText ? 0 : 20)
                    }
                    
                    Spacer()
                    
                    // Welcome Message
                    VStack(spacing: 10) {
                        Text("السَّلامُ عَلَيْكُمْ وَرَحْمَةُ اللهِ وَبَرَكاتُهُ")
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.white)
                        
                        Text("Peace be upon you and Allah's mercy and blessings")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.white)
                        
                        Text("Welcome to your spiritual companion")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                    .opacity(showWelcome ? 1 : 0)
                    .offset(y: showWelcome ? 0 : 20)
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                // Animate logo
                withAnimation(.easeInOut(duration: 1.2)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
                
                // Start rotating animation
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    self.rotationAngle = 360
                }
                
                // Show text with delay
                withAnimation(.easeIn.delay(0.5)) {
                    self.showText = true
                }
                
                // Show welcome text with delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn) {
                        self.showWelcome = true
                    }
                }
                
                // Navigate to main view after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
