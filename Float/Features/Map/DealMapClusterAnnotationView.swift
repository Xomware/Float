// DealMapClusterAnnotationView.swift
// Float

import MapKit
import UIKit

/// Annotation view for clustered deal pins — cyan circle with count badge.
final class DealMapClusterAnnotationView: MKAnnotationView {
    static let reuseID = "DealCluster"

    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()

    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0.706, blue: 0.847, alpha: 1) // #00b4d8
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        collisionMode = .circle
        addSubview(circleView)
        circleView.addSubview(badgeLabel)
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        centerOffset = CGPoint(x: 0, y: -20)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = bounds.size
        circleView.frame = bounds
        circleView.layer.cornerRadius = size.width / 2
        badgeLabel.frame = bounds
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let cluster = annotation as? MKClusterAnnotation else { return }
        badgeLabel.text = "\(cluster.memberAnnotations.count)"
        let size: CGFloat = sizeForCount(cluster.memberAnnotations.count)
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        centerOffset = CGPoint(x: 0, y: -size / 2)
    }

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                self.transform = self.isSelected ? CGAffineTransform(scaleX: 1.3, y: 1.3) : .identity
            }
        }
    }

    private func sizeForCount(_ count: Int) -> CGFloat {
        switch count {
        case 0...5: return 40
        case 6...20: return 50
        default: return 60
        }
    }
}
