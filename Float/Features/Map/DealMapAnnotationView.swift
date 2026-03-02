// DealMapAnnotationView.swift
// Float

import MapKit
import UIKit

/// Individual deal pin annotation view with category icon and pulse animation.
final class DealMapAnnotationView: MKAnnotationView {
    static let reuseID = "DealPin"
    static let clusterID = "DealCluster"

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let circleView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.5
        return view
    }()

    private let pulseView: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = Self.clusterID
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        collisionMode = .circle
        frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        centerOffset = CGPoint(x: 0, y: -18)

        addSubview(pulseView)
        addSubview(circleView)
        circleView.addSubview(iconImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.frame = bounds
        circleView.layer.cornerRadius = bounds.width / 2
        iconImageView.frame = bounds.insetBy(dx: 8, dy: 8)
        pulseView.frame = bounds.insetBy(dx: -4, dy: -4)
        pulseView.layer.cornerRadius = pulseView.bounds.width / 2
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let dealAnnotation = annotation as? DealMapAnnotation else { return }
        let pin = dealAnnotation.dealPin
        let color = uiColor(for: pin.category)
        circleView.backgroundColor = color
        pulseView.backgroundColor = color
        iconImageView.image = UIImage(systemName: iconName(for: pin.category))
    }

    /// Run pulse animation — call after adding to map for new pins.
    func animatePulse() {
        pulseView.alpha = 0.5
        pulseView.transform = .identity
        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseOut]) {
            self.pulseView.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            self.pulseView.alpha = 0
        }
    }

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                self.transform = self.isSelected ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            }
        }
    }

    // MARK: - Helpers

    private func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "drink": return "wineglass.fill"
        case "food": return "fork.knife"
        case "both": return "cart.fill"
        case "flash": return "bolt.fill"
        default: return "tag.fill"
        }
    }

    private func uiColor(for category: String) -> UIColor {
        switch category.lowercased() {
        case "drink": return UIColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1) // #4A90D9
        case "food": return UIColor(red: 0.49, green: 0.83, blue: 0.13, alpha: 1) // #7ED321
        case "both": return UIColor(red: 0.61, green: 0.35, blue: 0.71, alpha: 1) // #9B59B6
        case "flash": return UIColor(red: 0.95, green: 0.61, blue: 0.07, alpha: 1) // #F39C12
        default: return UIColor(red: 1, green: 0.55, blue: 0, alpha: 1) // #FF8C00
        }
    }
}
