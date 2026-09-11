import UIKit

final class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
    }
    
    private func setupGradient() {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        
        gradientLayer.locations = [0, 0.1, 0.3]
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.masksToBounds = true
        gradientLayer.add(gradientChangeAnimation, forKey: "locationsChange")
        
        layer.addSublayer(gradientLayer)
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        gradientLayer.cornerRadius = radius
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}

