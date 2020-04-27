
import Foundation
@testable import Beowulf
import XCTest

class AssetTest: XCTestCase {
    func testEncodable() {
        AssertEncodes(Asset(10, Symbol(5,"BWF")), Data("40420f00000000000542574600000000"))
        AssertEncodes(Asset(123_456.789, Symbol(5,"M")), Data("341cdcdf02000000054d000000000000"))
        AssertEncodes(Asset(10, Symbol(5,"BWF")), "10.00000 BWF")
        AssertEncodes(Asset(123_456.789, Symbol(5,"BWF")), "123456.78900 M")
        AssertEncodes(Asset(42, Symbol(0,"TOWELS")), "42 TOWELS")
        AssertEncodes(Asset(0.001, Symbol(5,"W")), "0.00100 W")
    }

    func testDecodable() throws {
        AssertDecodes(string: "10.00000 BWF", Asset(10, Symbol(5,"BWF")))
        AssertDecodes(string: "0.00100 W", Asset(0.001, Symbol(5,"W")))
        AssertDecodes(string: "1.20 DUCKS", Asset(1.2, Symbol(2,"DUCKS")))
        AssertDecodes(string: "0 BOO", Asset(0, Symbol(0,"BOO")))
        AssertDecodes(string: "12345678.99999 M", Asset(123_456_78.99999, Symbol(5,"M")))
    }
}
