import SwiftUI

struct GeometricPatternView: View {
    var body: some View {
        Canvas { context, size in
            // Draw geometric pattern
            let tileSize: CGFloat = 40
            let rows = Int(size.height / tileSize) + 1
            let cols = Int(size.width / tileSize) + 1
            
            for row in 0...rows {
                for col in 0...cols {
                    let x = CGFloat(col) * tileSize
                    let y = CGFloat(row) * tileSize
                    
                    // Draw star pattern
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: x + tileSize/2, y: y))
                            path.addLine(to: CGPoint(x: x + tileSize, y: y + tileSize/2))
                            path.addLine(to: CGPoint(x: x + tileSize/2, y: y + tileSize))
                            path.addLine(to: CGPoint(x: x, y: y + tileSize/2))
                            path.closeSubpath()
                        },
                        with: .color(.white),
                        lineWidth: 0.5
                    )
                }
            }
        }
        .opacity(0.05)
    }
}
