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
var CurrentKeys_ : [String] = []

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

public func GetAccounts(client: Beowulf.Client, accounts: [String]) -> [ExtendedAccount]?{
    let req = API.GetAccounts(names: accounts)
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

func sendTrx(client: Beowulf.Client, op: OperationType, chain: ChainId) -> API.TransactionConfirmation?{
    let req = API.GetDynamicGlobalProperties()
    do{
        let props = try client.sendSynchronous(req)
        print(props)
        print("Date now:", Date())
        let expirationTime = 59*60 //in second
        let expiry = Date().addingTimeInterval(TimeInterval(expirationTime)).timeIntervalSince1970// props!.time.addingTimeInterval(60)
        let expiration = Date(timeIntervalSince1970: expiry)
        print(expiration)
        let now = Date()
        let tx = Transaction(
            refBlockNum: UInt16(props!.headBlockNumber & 0xFFFF),
            refBlockPrefix: props!.headBlockId.prefix,
            expiration: expiration,
            createdTime: UInt64(now.timeIntervalSince1970),
            operations: [op],
            extensions: [])
        var keys : [PrivateKey] = []
        for key in CurrentKeys_{
            keys.append(PrivateKey(key)!)
        }
        guard let stx = try? tx.sign(usingKey: keys, forChain: chain) else {
            return nil
        }
        let txRes = try client.sendSynchronous(API.BroadcastTransaction(transaction: stx))
        print(txRes)
        return txRes
    }catch{
        return nil
    }
}

public func AccountCreate(client: Beowulf.Client, creator: String, newAccountName: String, publicKey: String, fee: String, chain: ChainId) -> API.TransactionConfirmation? {

    var err = ValidateNameAccount(account: newAccountName)
    if err != nil{
        return nil
    }else{
        let validate = ValidateFee(fee: fee, minFee: 10000)
        if validate == false{
            return nil
        }
        let pub = PublicKey(publicKey)!
        let keyAuth = Authority.Auth(pub, weight: 1)
        var keyAuths : [Authority.Auth<PublicKey>] = []
        keyAuths.append(keyAuth)
        let owner = Authority(weightThreshold: 1, accountAuths: [], keyAuths: keyAuths)
        let accountCreate = Operation.AccountCreate(
            fee: Asset(fee)!,
            creator: creator,
            newAccountName: newAccountName,
            owner: owner,
            jsonMetadata:""
        )
        
        return sendTrx(client: client, op: accountCreate, chain: chain)
    }
}

//public func AccountUpdate(client: Beowulf.Client, accountName: String, publicKey: String, fee: String, chain: ChainId) -> API.TransactionConfirmation? {
//
//    var err = ValidateNameAccount(account: accountName)
//    if err != nil{
//        return nil
//    }else{
//        let validate = ValidateFee(fee: fee, minFee: 1000)
//        if validate == false{
//            return nil
//        }
//        let pub = PublicKey(publicKey)!
//        let keyAuth = Authority.Auth(pub, weight: 1)
//        var keyAuths : [Authority.Auth<PublicKey>] = []
//        keyAuths.append(keyAuth)
//        let owner = Authority(weightThreshold: 1, accountAuths: [], keyAuths: keyAuths)
//        let accountCreate = Operation.AccountCreate(
//            fee: Asset(fee)!,
//            creator: creator,
//            newAccountName: newAccountName,
//            owner: owner,
//            jsonMetadata:""
//        )
//
//        return sendTrx(client: client, op: accountCreate, chain: chain)
//    }
//}

public func Transfer(client: Beowulf.Client, from: String, to: String, amount: String, fee: String, memo: String, chain: ChainId) -> API.TransactionConfirmation? {

    var valid = ValidateAmount(amount: amount)
    if valid == false{
        return nil
    }else{
        let validate = ValidateFee(fee: fee, minFee: 1000)
        if validate == false{
            return nil
        }
        
        let transferOp = Operation.Transfer(
            from: from,
            to: to,
            amount: Asset(amount)!,
            fee: Asset(fee)!,
            memo: memo)
        
        return sendTrx(client: client, op: transferOp, chain: chain)
    }
}
