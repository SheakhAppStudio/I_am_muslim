import UIKit

extension UIImage {
    static func gradientImage(
        bounds: CGRect,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0)
    ) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}
