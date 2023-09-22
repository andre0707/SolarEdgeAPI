import XCTest
@testable import SolarEdgeAPI

final class OtherTests: XCTestCase {
    
    func test_units() async throws {
        let unit = Unit(symbol: "Wh")
        
        let measurement = Measurement(value: 50_000, unit: unit)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        XCTAssertEqual(formatter.string(from: measurement), "50.000 Wh")
    }
}
