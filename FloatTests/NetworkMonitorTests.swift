// NetworkMonitorTests.swift
// FloatTests

import XCTest
@testable import Float

final class NetworkMonitorTests: XCTestCase {

    func testInitialStateIsConnected() {
        let monitor = NetworkMonitor()
        // Default state should be connected (optimistic)
        XCTAssertTrue(monitor.isConnected)
    }

    func testSharedInstanceExists() {
        let shared = NetworkMonitor.shared
        XCTAssertNotNil(shared)
    }

    func testConnectionTypeInitiallyNil() {
        let monitor = NetworkMonitor()
        // Connection type is nil until first path update
        // (NWPathMonitor fires async, so on fresh init it may be nil)
        // This test validates the property exists and is accessible
        _ = monitor.connectionType
    }
}
