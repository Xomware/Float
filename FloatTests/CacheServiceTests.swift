// CacheServiceTests.swift
// FloatTests

import XCTest
@testable import Float

final class CacheServiceTests: XCTestCase {

    var sut: CacheService!

    override func setUp() async throws {
        sut = CacheService()
        await sut.invalidateAll()
    }

    override func tearDown() async throws {
        await sut.invalidateAll()
        sut = nil
    }

    // MARK: - Store / Fetch Round-Trip

    func testStoreAndFetchRoundTrip() async {
        let deals = [
            Deal(id: UUID(), title: "Test Deal", category: "drink", venueId: UUID(),
                 discountType: "percentage", discountValue: 25)
        ]

        await sut.store(deals, key: "test.deals", ttl: 3600)
        let fetched: [Deal]? = await sut.fetch(key: "test.deals", type: [Deal].self)

        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.count, 1)
        XCTAssertEqual(fetched?.first?.title, "Test Deal")
    }

    // MARK: - TTL Expiry

    func testExpiredEntryReturnsNil() async {
        await sut.store("hello", key: "test.expiry", ttl: -1) // Already expired
        let fetched: String? = await sut.fetch(key: "test.expiry", type: String.self)
        XCTAssertNil(fetched)
    }

    func testNonExpiredEntryReturnsValue() async {
        await sut.store("hello", key: "test.valid", ttl: 3600)
        let fetched: String? = await sut.fetch(key: "test.valid", type: String.self)
        XCTAssertEqual(fetched, "hello")
    }

    // MARK: - No TTL (Permanent)

    func testPermanentCacheNeverExpires() async {
        await sut.store("permanent", key: "test.perm", ttl: nil)
        let fetched: String? = await sut.fetch(key: "test.perm", type: String.self)
        XCTAssertEqual(fetched, "permanent")
    }

    // MARK: - Invalidation

    func testInvalidateRemovesEntry() async {
        await sut.store("value", key: "test.invalidate", ttl: 3600)
        await sut.invalidate(key: "test.invalidate")
        let fetched: String? = await sut.fetch(key: "test.invalidate", type: String.self)
        XCTAssertNil(fetched)
    }

    func testInvalidateAllRemovesEverything() async {
        await sut.store("a", key: "test.a", ttl: 3600)
        await sut.store("b", key: "test.b", ttl: 3600)
        await sut.invalidateAll()

        let a: String? = await sut.fetch(key: "test.a", type: String.self)
        let b: String? = await sut.fetch(key: "test.b", type: String.self)
        XCTAssertNil(a)
        XCTAssertNil(b)
    }

    // MARK: - Codable Types

    func testVenueCodableRoundTrip() async {
        let venue = Venue(id: UUID(), name: "Test Bar", address: "123 Main St")
        await sut.store([venue], key: "test.venues", ttl: 3600)

        let fetched: [Venue]? = await sut.fetch(key: "test.venues", type: [Venue].self)
        XCTAssertEqual(fetched?.first?.name, "Test Bar")
        XCTAssertEqual(fetched?.first?.address, "123 Main St")
    }

    // MARK: - Cache Miss

    func testFetchNonexistentKeyReturnsNil() async {
        let result: String? = await sut.fetch(key: "nonexistent", type: String.self)
        XCTAssertNil(result)
    }
}
