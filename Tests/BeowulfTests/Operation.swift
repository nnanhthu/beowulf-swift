@testable import Beowulf
import XCTest

fileprivate let transfer = (
    Operation.Transfer(from: "foo", to: "bar", amount: Asset(10, Symbol(5,"BWF")), fee: Asset(10, Symbol(5,"W")), memo: "baz"),
    "{\"from\":\"foo\",\"to\":\"bar\",\"amount\":\"10.00000 BWF\",\"fee\":\"10.00000 W\",\"memo\":\"baz\"}"
)

let account_create = (
    Operation.AccountCreate(
        fee: Asset("10.00000 W")!,
        creator: "beowulf",
        newAccountName: "paulsphotography",
        owner: Authority(weightThreshold: 1, accountAuths: [], keyAuths: [[PublicKey("BEO8LMF1uA5GAPfsAe1dieBRATQfhgi1ZqXYRFkaj1WaaWx9vVjau")!: 1]]),
        
        jsonMetadata: ""
    ),
    "{\"fee\":\"10.00000 W\",\"creator\":\"beowulf\",\"new_account_name\":\"paulsphotography\",\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"BEO8LMF1uA5GAPfsAe1dieBRATQfhgi1ZqXYRFkaj1WaaWx9vVjau\",1]]},\"json_metadata\":\"\"}",
    Data("40420f000000000005570000000000000762656f77756c66107061756c7370686f746f67726170687901000000000103c5ce92a15f7120ae896f348c4ce505d9573cf0816338a478dd9845fe7b1ec59b010000")
)

class OperationTest: XCTestCase {
    func testEncodable() throws {
        
        AssertEncodes(transfer.0, Data("03666f6f0362617240420f0000000000054257460000000040420f000000000005570000000000000362617a"))
        AssertEncodes(transfer.0, ["from": "foo", "to": "bar", "amount": "10.00000 BWF","fee": "10.00000 W", "memo": "baz"])
        
        AssertEncodes(account_create.0, account_create.2)
    }

    func testDecodable() {
        
        AssertDecodes(json: transfer.1, transfer.0)
        AssertDecodes(json: account_create.1, account_create.0)
    }
}
