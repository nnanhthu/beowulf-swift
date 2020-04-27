@testable import Beowulf
import XCTest

struct HelloRequest: Request {
    typealias Response = String
    let method = "conveyor.hello"
    let params: RequestParams<String>? = RequestParams(["name": "foo"])
}

let client = Beowulf.Client(address: URL(string: "https://testnet-bw.beowulfchain.com/rpc")!)

let testnetClient = Beowulf.Client(address: URL(string: "https://testnet-bw.beowulfchain.com/rpc")!)
let testnetId = ChainId.custom(Data(hexEncoded: "430b37f23cf146d42f15376f341d7f8f5a1ad6f4e63affdeb5dc61d55d8c95a7"))

class ClientTest: XCTestCase {
    func testNani() {
        debugPrint(Data(hexEncoded: "430b37f23cf146d42f15376f341d7f8f5a1ad6f4e63affdeb5dc61d55d8c95a7").base64EncodedString())
    }

    func testRequest() {
        let test = expectation(description: "Response")
        client.send(HelloRequest()) { res, error in
            XCTAssertNil(error)
            XCTAssertEqual(res, "I'm sorry, foo, I can't do that.")
            test.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testGetVersion() {

        let test = expectation(description: "Response")
        let req = API.GetVersion()
        do{
            let res = try client.sendSynchronous(req)
            print(res)
        }catch{

        }
    }
    

    func testGetConfig() {

            let test = expectation(description: "Response")
            let req = API.GetConfig()
            do{
                let res = try client.sendSynchronous(req)
                print(res)
            }catch{

            }
        }
    
    func testGlobalProps() {

        let test = expectation(description: "Response")
        let req = API.GetDynamicGlobalProperties()
        do{
            let res = try client.sendSynchronous(req)
            print(res)
        }catch{
            
        }
//        client.send(req) { res, error in
//            XCTAssertNil(error)
//            XCTAssertNotNil(res)
////            XCTAssertEqual(res?.currentSupply.symbol.name, "BWF")
//            test.fulfill()
//        }
//        waitForExpectations(timeout: 5) { error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//            }
//        }
    }

    func testGetSupernodeSchedule() {

            let test = expectation(description: "Response")
//        let req = API.GetHardforkVersion()
//            let req = API.GetSupernodeSchedule()
//        let req = API.GetTransaction(txId: "d0bf0b4aaff82b925de2d9a1451478cc10dd7c1e")
//        let req = API.GetSupernodes(ids: [1])
//        let req = API.GetSupernodeByVote(lowerBound: "a",limit: 10)
//        let req = API.LookupSupernodeAccounts(lowerBound: "a",limit: 10)
//        let req = API.GetSupernodeVoted(account:"beowulf")
//        let req = API.GetKeyReferences(publicKey:["BEO5r5ceRhRFe4j1BCpp4eKwLkB7MRo41yrGzpjHakTB4KDMicxnC"])
//        let req = API.ListTokens()
//        let req = API.GetTokens(name: ["NLP"])
        let req = API.GetBalance(account: "nghia", tokenName: "NLP", decimals: 5)
            do{
                let res = try client.sendSynchronous(req)
                print(res)
            }catch{
                
            }
        }
    
    func testGetBlock() {
        var res = GetBlock(client: client, blockNum: 3584405)
        print (res)
//        let test = expectation(description: "Response")
//        let req = API.GetBlock(blockNum: 3584405)
//        do{
//            let res = try client.sendSynchronous(req)
//            print(res)
//        }catch{
//
//        }
//        client.send(req) { block, error in
//            XCTAssertNil(error)
//            XCTAssertEqual(block?.previous.num, 12_345_677)
//            XCTAssertEqual(block?.transactions.count, 7)
//            test.fulfill()
//        }
//        waitForExpectations(timeout: 5) { error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//            }
//        }
    }

    func testGetBlockHeader() {
            let test = expectation(description: "Response")
            let req = API.GetBlockHeader(blockNum: 3584405)
            do{
                let res = try client.sendSynchronous(req)
                print(res)
            }catch{
                
            }
        }
    
    func testBroadcast() {
//        let test = expectation(description: "Response")
//        let key = PrivateKey("5JQzF7rejVDDFYqCtm4ypcNHhP8Zru6hY1bpALxjNWKtm2yBqC9")!
//        var comment = Operation.AccountCreate((
//            title: "Hello from Swift",
//            body: "The time is \(Date()) and I'm running tests.",
//            author: "swift",
//            permlink: "hey-eveyone-im-running-swift-tests-and-the-time-is-\(UInt32(Date().timeIntervalSinceReferenceDate))"
//        )
//        comment.parentPermlink = "test"
//        let vote = Operation.Vote(voter: "swift", author: "swift", permlink: comment.permlink)
//        testnetClient.send(API.GetDynamicGlobalProperties()) { props, error in
//            XCTAssertNil(error)
//            guard let props = props else {
//                return XCTFail("Unable to get props")
//            }
//            let expiry = props.time.addingTimeInterval(60)
//            let tx = Transaction(
//                refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
//                refBlockPrefix: props.headBlockId.prefix,
//                expiration: expiry,
//                operations: [comment, vote])
//            guard let stx = try? tx.sign(usingKey: key, forChain: testnetId) else {
//                return XCTFail("Unable to sign tx")
//            }
//            testnetClient.send(API.BroadcastTransaction(transaction: stx)) { res, error in
//                XCTAssertNil(error)
//                if let res = res {
//                    XCTAssertFalse(res.expired)
//                    XCTAssert(res.blockNum > props.headBlockId.num)
//                } else {
//                    XCTFail("No response")
//                }
//                test.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 10) { error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//            }
//        }
    }

    func testGetAccount() throws {
        let test = expectation(description: "Response")
        let req = API.GetAccounts(names: ["beowulf"])
        do{
            let res = try client.sendSynchronous(req)
            print(res)
        }catch{
            
        }
//        let result = try client.sendSynchronous(API.GetAccounts(names: ["almost-digital"]))
//        guard let account = result?.first else {
//            XCTFail("No account returned")
//            return
//        }
//        XCTAssertEqual(account.id, 180_270)
//        XCTAssertEqual(account.name, "almost-digital")
//        XCTAssertEqual(account.created, Date(timeIntervalSince1970: 1_496_691_060))
    }
}
