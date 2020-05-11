@testable import Beowulf
import XCTest

class TransactionTest: XCTestCase {
    override class func setUp() {
        PrivateKey.determenisticSignatures = true
    }

    override class func tearDown() {
        PrivateKey.determenisticSignatures = false
    }

    func testDecodable() throws {
        let tx = try TestDecode(Transaction.self, json: txJson)
        XCTAssertEqual(tx.refBlockNum, 12345)
        XCTAssertEqual(tx.refBlockPrefix, 1_122_334_455)
        XCTAssertEqual(tx.expiration, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(tx.extensions.count, 0)
        XCTAssertEqual(tx.operations.count, 1)
//        let vote = tx.operations.first as? Beowulf.Operation.Vote
        let transfer = tx.operations.last as? Beowulf.Operation.Transfer
//        XCTAssertEqual(vote, Beowulf.Operation.Vote(voter: "foo", author: "bar", permlink: "baz", weight: 1000))
        XCTAssertEqual(transfer, Beowulf.Operation.Transfer(from: "foo", to: "bar", amount: Asset(10, Symbol(5,"BWF")), fee: Asset(10, Symbol(5,"W")), memo: "baz"))
    }

    func testSigning() throws {
        guard let key = PrivateKey("5JEB2fkmEqHSfGqL96eTtQ2emYodeTBBnXvETwe2vUSMe4pxdLj") else {
            return XCTFail("Unable to parse private key")
        }
        let operations: [OperationType] = [
//            Operation.Vote(voter: "foo", author: "foo", permlink: "baz", weight: 1000),
            Operation.Transfer(from: "foo", to: "bar", amount: Asset(10, Symbol(5,"BWF")), fee: Asset(10, Symbol(5,"W")), memo: "baz"),
        ]
        let expiration = Date(timeIntervalSince1970: 0)
        let transaction = Transaction(refBlockNum: 0, refBlockPrefix: 0, expiration: expiration, createdTime: 0, operations: operations)
        AssertEncodes(transaction, Data("00000000000000000000010003666f6f0362617240420f0000000000054257460000000040420f000000000005570000000000000362617a000000000000000000"))
        XCTAssertEqual(try transaction.digest(forChain: .mainNet), Data("44424a1259aba312780ca6957a91dbd8a8eef8c2c448d89eccee34a425c77512"))
        let customChain = Data("79276aea5d4877d9a25892eaa01b0adf019d3e5cb12a97478df3298ccdd01673")
        XCTAssertEqual(try transaction.digest(forChain: .custom(customChain)), Data("43ca08db53ad0289ccb268654497e0799c02b50ac8535e0c0f753067417be953"))
        var signedTransaction = try transaction.sign(usingKey: [key])
        try signedTransaction.appendSignature(usingKey: key, forChain: .custom(customChain))
        XCTAssertEqual(signedTransaction.signatures, [
            Signature("1f6a3575e6e47fe5726579107a7e42d58d897efc74f7110bac8d5c12d009ecfb6b3731449328693b7b6fbbc835fe55f9cdb9a539219ef5c9af744a9c1b6a42fce0"),
            Signature("206ba57b4a716915f68ae10e0ee5c05c389ea2b9fca749e308fb4257961ffe4c917aef8a848dbbb1b75fb504bb608856d62be741dd008dd5888d4058ed13672d8e"),
        ])
    }
}

fileprivate let txJson = """
{
  "ref_block_num": 12345,
  "ref_block_prefix": 1122334455,
  "expiration": "1970-01-01T00:00:00",
  "extensions": [],
  "operations": [
    
    ["transfer", {"from": "foo", "to": "bar", "amount": "10.00000 BWF", "fee": "10.00000 W","memo": "baz"}]
  ]
}
"""
