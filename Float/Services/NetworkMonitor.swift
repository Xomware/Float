// NetworkMonitor.swift
// Float

import Foundation
import Network
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Network")

@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()

    var isConnected: Bool = true
    var connectionType: NWInterface.InterfaceType?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.xomware.float.networkmonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
                logger.info("Network status: \(path.status == .satisfied ? "connected" : "disconnected")")
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
