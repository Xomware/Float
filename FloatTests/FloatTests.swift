import XCTest
@testable import Float

final class FloatTests: XCTestCase {
    func testColorsExist() {
        XCTAssertNotNil(FloatColors.primary)
        XCTAssertNotNil(FloatColors.accent)
        XCTAssertNotNil(FloatColors.background)
    }
    
    func testSpacingValues() {
        XCTAssertEqual(FloatSpacing.xs, 4)
        XCTAssertEqual(FloatSpacing.md, 16)
        XCTAssertEqual(FloatSpacing.cardRadius, 16)
    }
    
    func testDateExtensions() {
        let futureDate = Date().addingTimeInterval(1800) // 30 min from now
        XCTAssertTrue(futureDate.isExpiringSoon)
        XCTAssertFalse(futureDate.isExpired)
        
        let pastDate = Date().addingTimeInterval(-100)
        XCTAssertTrue(pastDate.isExpired)
    }
}
