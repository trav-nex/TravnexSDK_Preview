//
//  TravnexButton.swift
//  TravnexSDK-Preview
//
//  Created by Dominic Thompson on 11/4/24.
//



import UIKit

public class TravnexButton: UIButton {
    // MARK: - Properties
    private let buttonSize: CGFloat = 60
    private let rippleLayer = CAShapeLayer()
    
    //Public Position Enum
    public enum Position{
        case bottomRight
        case bottomLeft
        case topRight
        case topLeft
        case custom([NSLayoutConstraint])
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    // MARK: - Setup
    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Visual setup
        backgroundColor = UIColor(red: 182/255, green: 213/255, blue: 45/255, alpha: 1.0)
        layer.cornerRadius = buttonSize / 2
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        clipsToBounds = false
        
        // Icon setup
        setupIcon()
        
        // Touch animation setup
        setupTouchAnimation()
        
        // Ripple effect setup
        setupRippleEffect()
        
        // Size constraints
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: buttonSize),
            heightAnchor.constraint(equalToConstant: buttonSize)
        ])
    }
    
    private func setupIcon() {
        // If using custom image
        if let iconImage = UIImage(named: "travnex-icon") {
            setImage(iconImage.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            // Fallback to SF Symbol
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            let fallbackImage = UIImage(systemName: "waveform.circle.fill", withConfiguration: config)
            setImage(fallbackImage, for: .normal)
        }
        
        tintColor = .white
        imageView?.contentMode = .scaleAspectFit
//        imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    private func setupTouchAnimation() {
        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func setupRippleEffect() {
        rippleLayer.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
        layer.addSublayer(rippleLayer)
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        rippleLayer.frame = bounds
    }
    
    // MARK: - Animation Methods
    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState]) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        animateRipple()
    }
    
    @objc private func buttonTouchUp() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState]) {
            self.transform = .identity
        }
    }
    
    private func animateRipple() {
        let ripplePath = UIBezierPath(ovalIn: bounds).cgPath
        rippleLayer.path = ripplePath
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        animationGroup.duration = 0.4
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        rippleLayer.add(animationGroup, forKey: "ripple")
    }
}

// MARK: - Convenience Extension for UIView

public extension UIView {
    @discardableResult
    func addTravnexButton(position: TravnexButton.Position = .bottomRight, margins: UIEdgeInsets = .init(top: 0, left: 0, bottom: 20, right: 20)) -> TravnexButton {
        let button = TravnexButton()
        addSubview(button)
        
        switch position {
        case .bottomRight:
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -margins.right),
                button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -margins.bottom)
            ])
        case .bottomLeft:
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margins.left),
                button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -margins.bottom)
            ])
        case .topRight:
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -margins.right),
                button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margins.top)
            ])
        case .topLeft:
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margins.left),
                button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margins.top)
            ])
        case .custom(let constraints):
            NSLayoutConstraint.activate(constraints)
        }
        
        return button
    }
}
