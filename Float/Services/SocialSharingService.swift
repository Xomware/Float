// SocialSharingService.swift
// Float

import SwiftUI
import UIKit

// MARK: - SocialSharingService

final class SocialSharingService {
    static let shared = SocialSharingService()
    private init() {}

    /// Build a shareable string for a deal.
    func shareText(for deal: Deal) -> String {
        var parts: [String] = []
        parts.append("🎉 \(deal.title)")
        if let venueName = deal.venueName {
            parts.append("📍 \(venueName)")
        }
        if !deal.discountDisplay.isEmpty {
            parts.append("💰 \(deal.discountDisplay)")
        }
        if let expiresAt = deal.expiresAt {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            parts.append("⏰ Expires \(formatter.localizedString(for: expiresAt, relativeTo: Date()))")
        }
        parts.append("\nFound on Float 🌊")
        parts.append("float://deal/\(deal.id.uuidString)")
        return parts.joined(separator: "\n")
    }

    /// Present the native iOS share sheet for a deal.
    func shareDeal(_ deal: Deal, from viewController: UIViewController? = nil) {
        let text = shareText(for: deal)
        let items: [Any] = [text]

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Exclude less useful activity types
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
            .markupAsPDF,
            .saveToCameraRoll
        ]

        // Present
        let vc = viewController ?? topViewController()
        vc?.present(activityVC, animated: true)

        AnalyticsService.shared.track("deal_shared", properties: [
            "deal_id": deal.id.uuidString,
            "venue": deal.venueName ?? "",
            "method": "share_sheet"
        ])
    }

    // MARK: - Helper

    private func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

// MARK: - ShareSheet SwiftUI Wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = [.assignToContact, .addToReadingList, .saveToCameraRoll]
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
