import SwiftUI

struct ModernPatternView: View {
    var body: some View {
        Canvas { context, size in
            // Draw modern pattern
            let lineSpacing: CGFloat = 30
            let lines = Int(size.width / lineSpacing) + 1
            
            // Draw diagonal lines
            for i in 0...lines {
                let x = CGFloat(i) * lineSpacing
                
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: x))
                    },
                    with: .color(.white),
                    lineWidth: 0.5
                )
                
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: size.height))
                        path.addLine(to: CGPoint(x: size.width, y: x))
                    },
                    with: .color(.white),
                    lineWidth: 0.5
                )
            }
        }
        .opacity(0.05)
    }
}
