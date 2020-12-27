@testable import Beowulf
import XCTest
import CommonCrypto

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
        let req = API.GetTransaction(txId: "5473e47bd6d969741f0ea328a19884c4cfc10819")
//        let req = API.GetSupernodes(ids: [1])
//        let req = API.GetSupernodeByVote(lowerBound: "a",limit: 10)
//        let req = API.LookupSupernodeAccounts(lowerBound: "a",limit: 10)
//        let req = API.GetSupernodeVoted(account:"beowulf")
//        let req = API.GetKeyReferences(publicKey:["BEO5r5ceRhRFe4j1BCpp4eKwLkB7MRo41yrGzpjHakTB4KDMicxnC"])
//        let req = API.ListTokens()
//        let req = API.GetTokens(name: ["NLP"])
//        let req = API.GetBalance(account: "nghia", tokenName: "NLP", decimals: 5)
            do{
                let res = try client.sendSynchronous(req)
                print(res)
            }catch{
                
            }
        }
    
    func testGetBlock() {
//        var res = GetBlock(client: client, blockNum: 3584405)
//        print (res)
        
//        var res = GetAccounts(client: client, account: "beowulf")
//        print (res)
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
        ImportKey(wif: "5JEsAzMxv5E1djK7EGzeBCG85EeHf798UJbEYfSKihM1vTVVwQc", name: "initminer")
//        let wl = GenKeys(newAccountName: "test")
//        SaveWalletFile(walletPath: "wallet", walletFilename: "", password: "12345678", walletData: wl)
        SetKeysFromFileWallet(pathFileWallet: "wallet/test-wallet.json", password: "12345678")
        
        
    }

    func testGetAccount() throws {
//        let test = expectation(description: "Response")
//        let req = API.GetAccounts(names: ["beowulf"])
//        do{
//            let res = try client.sendSynchronous(req)
//            print(res)
//        }catch{
//
//        }
//        let acc = GetAccounts(client: client, accounts: ["beowulf"])
        let balance = GetBalance(client: client, account: "beowulf", tokenName: "W", decimals: 5)
        print(balance)
//        let result = try client.sendSynchronous(API.GetAccounts(names: ["almost-digital"]))
//        guard let account = result?.first else {
//            XCTFail("No account returned")
//            return
//        }
//        XCTAssertEqual(account.id, 180_270)
//        XCTAssertEqual(account.name, "almost-digital")
//        XCTAssertEqual(account.created, Date(timeIntervalSince1970: 1_496_691_060))
    }
    
    func testValidate(){
//        var str = ValidateNameAccount(account: "aaa-4")
//        var valid = ValidateFee(fee: "0.01000 W", minFee: 1000)
//        var str = RandStringBytes(length: 10)
//        var wallet = GenKeys(newAccountName: "acc2")
        var keys : [String:String] = [:]
        keys["BEO57qTuXxtnc7KDJ4t5zSoJimzpR2SgV9SQDsu5q4NMSkKLUwsA6"] =
            "5JHTf7dkpVxQNcb5NWc7URTrHDgAFEyxn2BEnMjuJ6fJrCAniCQ"
//        keys["BEO5r5ceRhRFe4j1BCpp4eKwLkB7MRo41yrGzpjHakTB4KDMicxnC"] = "5JrfnT23TfZSg6xHtBpsc7NRuGNakCiGUZ5WN1tNUJBVkWapYfb"
        SetKeys(keys: keys)
//        var trx = AccountCreate(client: client, creator: "beowulf", newAccountName: "acc2", publicKey: wallet!.publicKey, fee: "0.10000 W", chain: .testNet)
        
//        var trx = Transfer(client: client, from: "beowulf", to: "thaiw1", amount: "100.00000 BWF", fee: "0.01000 W", memo: "", chain: .testNet)
//        trx = Transfer(client: client, from: "beowulf", to: "thaiw1", amount: "100.00000 W", fee: "0.01000 W", memo: "", chain: .testNet)
        
        let trans = GetTransaction(client: client, trxId: "d1740273eef7790f345c70d109709072f050d818")
        print (trans)
    }
}
