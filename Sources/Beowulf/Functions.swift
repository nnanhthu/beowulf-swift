//
//  File.swift
//  
//
//  Created by Thu on 4/27/20.
//

import Crypto
import CommonCrypto
import Foundation

var Keys_: [String: String] = [:]
var Checksum_: [UInt8] = []
var Wallet_ = Wallet()
var Locked = true
var WalletName_ = "wallet.json"

public func GetBlock(client: Beowulf.Client, blockNum: Int) -> SignedBlock?{
    let req = API.GetBlock(blockNum: blockNum)
    do{
        let res = try client.sendSynchronous(req)
        return res
    }catch{
        
    }
    return nil
}

public func GetTransaction(client: Beowulf.Client, trxId: String) -> TransactionResponse?{
    let req = API.GetTransaction(txId: trxId)
    do{
        let res = try client.sendSynchronous(req)
        return res
    }catch{
        
    }
    return nil
}

func matchesRegex(regex: String, text: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(location: 0, length: text.count))
        let finalResult = results.map {
            (text as NSString).substring(with: $0.range)
        }
        var res = ""
        for str in finalResult{
            res = res+str
            if res == text{
                return true
            }
        }
        return false
    } catch let error {
        print("error regex: \(error.localizedDescription)")
        return false
    }
}


func ValidateNameAccount(account: String) -> String?{
    if account.isEmpty{
        return "Name account is not empty"
    }else if account.count < 3 || account.count > 16{
        return "Name length is from 3 to 16 characters"
    }
    let matching = matchesRegex(regex: "[a-z0-9-]", text: account)
    if matching{
        return nil
    }
    return "Name contains character invalid"
}

func ValidateFee(fee:String, minFee:Int64) -> Bool{
    let asset = Asset(fee)
    if asset == nil{
        return false
    }
    if asset?.symbol.name != "W"{
        return false
    }
    if asset!.amount < minFee{
        return false
    }
    return true
}

func ValidateAmount(amount:String) -> Bool{
    let asset = Asset(amount)
    if asset == nil{
        return false
    }
    if asset!.amount <= 0{
        return false
    }
    return true
}



//public func AccountCreate(client: Beowulf.Client, creator: String, newAccountName: String, publicKey: String, fee: String, chain: ChainId) {
//
//    var err = ValidateNameAccount(account: newAccountName)
//    if err != nil{
//        return nil
//    }else{
//        var validate = ValidateFee(fee: fee, minFee: 10000)
//        if validate == false{
//            return nil
//        }
//        var pub = PublicKey(publicKey)
//        var keyAuth = Authority.Auth(pub, weight: 1)
//        var owner = Authority(weightThreshold: 1, accountAuths: [], keyAuths: [keyAuth])
//        var comment = Operation.AccountCreate((
//            fee: Asset(fee),
//            creator: creator,
//            newAccountName: newAccountName,
//            owner: owner
//            jsonMetadata:""
//        ))
//
//        client.send(API.GetDynamicGlobalProperties()) { props, error in
//            XCTAssertNil(error)
//            guard let props = props else {
//                return XCTFail("Unable to get props")
//            }
//            let expiry = props.time.addingTimeInterval(60)
//            let tx = Transaction(
//                refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
//                refBlockPrefix: props.headBlockId.prefix,
//                expiration: expiry,
//                operations: [comment])
//            guard let stx = try? tx.sign(usingKey: key, forChain: chain) else {
//                return XCTFail("Unable to sign tx")
//            }
//            client.send(API.BroadcastTransaction(transaction: stx)) { res, error in
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
//    }
//}

