@testable import Beowulf
import XCTest

fileprivate let transfer = (
    Operation.Transfer(from: "foo", to: "bar", amount: Asset(10, .beowulf), fee: Asset(10, .wd), memo: "baz"),
    "{\"from\":\"foo\",\"to\":\"bar\",\"amount\":\"10.000 BWF\",\"memo\":\"baz\"}"
)

let account_create = (
    Operation.AccountCreate(
        fee: Asset("10.000 BWF")!,
        creator: "beowulf",
        newAccountName: "paulsphotography",
        owner: Authority(weightThreshold: 1, accountAuths: [], keyAuths: [[PublicKey("STM8LMF1uA5GAPfsAe1dieBRATQfhgi1ZqXYRFkaj1WaaWx9vVjau")!: 1]]),
        
        jsonMetadata: ""
    ),
    "{\"fee\":\"10.000 BWF\",\"creator\":\"beowulf\",\"new_account_name\":\"paulsphotography\",\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"STM8LMF1uA5GAPfsAe1dieBRATQfhgi1ZqXYRFkaj1WaaWx9vVjau\",1]]},\"active\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"STM56WPHZKvxoHpjQh69XakuoE5czuewrTDYeUBsQNKjnq3a6bbh6\",1]]},\"posting\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"STM5oPsxWgfCH2FWqcXBWeeMmZoyBY5baiuV1vQWMxVVpYxEsJ6Hx\",1]]},\"memo_key\":\"STM7SSqMsrCqNZ3NdJLwWqC2u5PQ66JB2uCCs6ee5NFFqXxxB46AH\",\"json_metadata\":\"\"}",
    Data("102700000000000003535445454d000005737465656d107061756c7370686f746f67726170687901000000000103c5ce92a15f7120ae896f348c4ce505d9573cf0816338a478dd9845fe7b1ec59b0100010000000001021b49b04b2406912fbd4a183512b3cdf72c215eba13ceb0c9700db4fbef1dc2570100010000000001027820f0c756d3bc57ce05547fe828d20e03b7fc74e8e4968f984e38b3e26449cb0100034ff417d40dae1849b2187ebd4514b8068db851b73bee6f4c7903e7c8677059ef00")
)

class OperationTest: XCTestCase {
    func testEncodable() throws {
        
        AssertEncodes(transfer.0, Data("03666f6f03626172102700000000000003535445454d00000362617a"))
        AssertEncodes(transfer.0, ["from": "foo", "to": "bar", "amount": "10.000 BWF", "memo": "baz"])
        
        AssertEncodes(account_create.0, account_create.2)
    }

    func testDecodable() {
        
        AssertDecodes(json: transfer.1, transfer.0)
        AssertDecodes(json: account_create.1, account_create.0)
    }
}
