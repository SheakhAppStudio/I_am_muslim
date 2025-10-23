import SwiftUI

struct ArabesquePatternView: View {
    var body: some View {
        Canvas { context, size in
            // Draw arabesque pattern
            let tileSize: CGFloat = 60
            let rows = Int(size.height / tileSize) + 1
            let cols = Int(size.width / tileSize) + 1
            
            for row in 0...rows {
                for col in 0...cols {
                    let x = CGFloat(col) * tileSize
                    let y = CGFloat(row) * tileSize
                    
                    // Draw floral pattern
                    context.stroke(
                        Path { path in
                            // Main circle
                            path.addEllipse(in: CGRect(x: x + tileSize/4, y: y + tileSize/4,
                                                      width: tileSize/2, height: tileSize/2))
                            
                            // Petals
                            for angle in stride(from: 0, to: 360, by: 45) {
                                let radian = CGFloat(angle) * .pi / 180
                                let centerX = x + tileSize/2
                                let centerY = y + tileSize/2
                                let petalLength = tileSize/3
                                
                                path.move(to: CGPoint(x: centerX, y: centerY))
                                path.addCurve(
                                    to: CGPoint(x: centerX + petalLength * cos(radian),
                                              y: centerY + petalLength * sin(radian)),
                                    control1: CGPoint(x: centerX + petalLength/2 * cos(radian - 0.5),
                                                    y: centerY + petalLength/2 * sin(radian - 0.5)),
                                    control2: CGPoint(x: centerX + petalLength/2 * cos(radian + 0.5),
                                                    y: centerY + petalLength/2 * sin(radian + 0.5))
                                )
                            }
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
