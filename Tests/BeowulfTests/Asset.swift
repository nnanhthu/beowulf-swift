
import Foundation
@testable import Beowulf
import XCTest

class AssetTest: XCTestCase {
    func testEncodable() {
        AssertEncodes(Asset(10, .beowulf), Data("40420f00000000000542574600000000"))
        AssertEncodes(Asset(123_456.789, .vests), Data("341cdcdf02000000054d000000000000"))
        AssertEncodes(Asset(10, .beowulf), "10.00000 BWF")
        AssertEncodes(Asset(123_456.789, .vests), "123456.78900 M")
        AssertEncodes(Asset(42, .custom(name: "TOWELS", precision: 0)), "42 TOWELS")
        AssertEncodes(Asset(0.001, .wd), "0.00100 W")
    }

    func testDecodable() throws {
        AssertDecodes(string: "10.00000 BWF", Asset(10, .beowulf))
        AssertDecodes(string: "0.00100 W", Asset(0.001, .wd))
        AssertDecodes(string: "1.20 DUCKS", Asset(1.2, .custom(name: "DUCKS", precision: 2)))
        AssertDecodes(string: "0 BOO", Asset(0, .custom(name: "BOO", precision: 0)))
        AssertDecodes(string: "12345678.99999 M", Asset(123_456_78.99999, .vests))
    }
}
