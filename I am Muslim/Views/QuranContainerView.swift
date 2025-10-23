import SwiftUI

struct QuranContainerView: View {
    @State private var isReadMode = false
    
    enum QuranMode {
        case read
        case listen
        
        var title: String {
            switch self {
            case .read: return "Read Quran"
            case .listen: return "Listen Quran"
            }
        }
        
        var icon: String {
            switch self {
            case .read: return "book.fill"
            case .listen: return "headphones"
            }
        }
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
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar with Mode Toggle
                    HStack {
                        Text(isReadMode ? QuranMode.read.title : QuranMode.listen.title)
                            .font(.system(.title2, design: .serif))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Custom Toggle Button
                        Button(action: {
                            withAnimation {
                                isReadMode.toggle()
                            }
                        }) {
                            HStack(spacing: 20) {
                                Text("Listen")
                                    .foregroundColor(isReadMode ? .gray : .white)
                                    .font(.system(.headline, design: .serif))
                                
                                Text("Read")
                                    .foregroundColor(isReadMode ? .white : .gray)
                                    .font(.system(.headline, design: .serif))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    
                    // Content View with smooth transition
                    ZStack {
                        if isReadMode {
                            ReadQuranView()
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                        } else {
                            QuranView()
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isReadMode)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    QuranContainerView()
}
