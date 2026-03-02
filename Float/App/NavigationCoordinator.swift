// NavigationCoordinator.swift
// Float

import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Navigation")

/// Coordinates navigation events triggered from outside the SwiftUI view hierarchy
/// (e.g., notification deep links).
@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var pendingDealId: UUID?

    func navigateToDeal(_ dealId: UUID) {
        logger.info("Navigation requested to deal: \(dealId)")
        pendingDealId = dealId
    }

    func clearPendingNavigation() {
        pendingDealId = nil
    }
}
