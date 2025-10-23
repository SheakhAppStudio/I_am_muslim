import SwiftUI
import AVKit

// MARK: - Live Stream Player
struct LiveStreamPlayerView: View {
    let stream: LiveStreamItem
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var mediaService = MediaService.shared
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom navigation bar with Islamic styling
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    Text("Live Stream")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.8))
                
                // Video Player
                GeometryReader { geometry in
                    if let url = URL(string: stream.streamUrl) {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: geometry.size.width * 9/16)
                    }
                }
                .frame(height: UIScreen.main.bounds.width * 9/16)
                
                // Stream Info with Islamic styling
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(stream.title)
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                    }
                    .padding()
                }
            }
        }
        .statusBar(hidden: true)
    }
}
