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
        return res.0
    }catch{
        
    }
    return nil
}

public func GetTransaction(client: Beowulf.Client, trxId: String) -> TransactionResponse?{
    let req = API.GetTransaction(txId: trxId)
    do{
        let res = try client.sendSynchronous(req)
        return res.0
    }catch{
        
    }
    return nil
}

public func GetAccounts(client: Beowulf.Client, accounts: [String]) -> [ExtendedAccount]?{
    let req = API.GetAccounts(names: accounts)
    do{
        let res = try client.sendSynchronous(req)
        return res.0
    }catch{
        
    }
    return nil
}

public func GetBalance(client: Beowulf.Client, account: String, tokenName: String, decimals: UInt8) -> String?{
    let req = API.GetBalance(account: account, tokenName: tokenName, decimals: decimals)
    do{
        let res = try client.sendSynchronous(req)
        return res.0
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
    return nil
//    if account.isEmpty{
//        return "Name account is not empty"
//    }else if account.count < 3 || account.count > 16{
//        return "Name length is from 3 to 16 characters"
//    }
//    let matching = matchesRegex(regex: "[a-z0-9-]", text: account)
//    if matching{
//        return nil
//    }
//    return "Name contains character invalid"
}

func ValidateFee(fee:String, minFee:Int64) -> Bool{
//    let asset = Asset(fee)
//    if asset == nil{
//        return false
//    }
//    if asset?.symbol.name != "W"{
//        return false
//    }
//    if asset!.amount < minFee{
//        return false
//    }
    return true
}

func ValidateAmount(amount:String) -> Bool{
//    let asset = Asset(amount)
//    if asset == nil{
//        return false
//    }
//    if asset!.amount <= 0{
//        return false
//    }
    return true
}

func sendTrx(client: Beowulf.Client, op: OperationType, chain: ChainId) -> (API.TransactionConfirmation?, Swift.Error?){
    let req = API.GetDynamicGlobalProperties()
    do{
        let properties = try client.sendSynchronous(req)
        let props = properties.0
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
            return (nil, Secp256k1Context.Error.signingFailed)
        }
        let txRes = try client.sendSynchronous(API.BroadcastTransaction(transaction: stx))
        print(txRes)
        if let error = txRes.1{
            return (nil, error)
        }
        return (txRes.0, nil)
    }catch{
        //return (nil
        return (nil, error)
    }
}

public func AccountCreate(client: Beowulf.Client, creator: String, newAccountName: String, publicKey: String, fee: String, chain: ChainId) -> (API.TransactionConfirmation?, Swift.Error?) {

    var err = ValidateNameAccount(account: newAccountName)
    if err != nil{
        return (nil,nil)
    }else{
        let validate = ValidateFee(fee: fee, minFee: 10000)
        if validate == false{
            return (nil,nil)
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

public func CreateMultiSigAccount(client: Beowulf.Client, creator: String, newAccountName: String, fee: String, accounts: [String], keys: [String], threshold: UInt32, chain: ChainId) -> (API.TransactionConfirmation?, Swift.Error?) {
    let err = ValidateNameAccount(account: newAccountName)
    if err != nil {
        return (nil,nil)
    }
    let validate = ValidateFee(fee: fee, minFee: 10000)
    if validate == false {
        return (nil,nil)
    }
    var accountOwners = accounts
    var keyOwners = keys
    
    if keyOwners.count + accountOwners.count == 0 {
        return (nil,nil) //, errors.New("accountOwners + keyOwners is not empty")
    }
    if threshold == 0 || threshold > uint32(keyOwners.count + accountOwners.count) {
        return (nil,nil) //, errors.New("threshold is not valid")
    }
    //Sort owners
    if accountOwners.count > 1 {
        accountOwners.sort()
    }
    if keyOwners.count > 1 {
        keyOwners.sort()
    }
    
    var ownerAuths : [Authority.Auth<String>] = []
    var keyAuths : [Authority.Auth<PublicKey>] = []
    for accountOwner in accountOwners{
        let ownerAuth = Authority.Auth(accountOwner, weight: 1)
        ownerAuths.append(ownerAuth)
    }
    for publicKey in keyOwners{
        let pub = PublicKey(publicKey)!
        let keyAuth = Authority.Auth(pub, weight: 1)
        keyAuths.append(keyAuth)
    }
    
    let owner = Authority(weightThreshold: threshold, accountAuths: ownerAuths, keyAuths: keyAuths)
    let accountCreate = Operation.AccountCreate(
        fee: Asset(fee)!,
        creator: creator,
        newAccountName: newAccountName,
        owner: owner,
        jsonMetadata:""
    )
    
    return sendTrx(client: client, op: accountCreate, chain: chain)
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

public func Transfer(client: Beowulf.Client, from: String, to: String, amount: String, fee: String, memo: String, chain: ChainId) -> (API.TransactionConfirmation?, Swift.Error?) {

    var valid = ValidateAmount(amount: amount)
    if valid == false{
        return (nil,nil)
    }else{
        let validate = ValidateFee(fee: fee, minFee: 1000)
        if validate == false{
            return (nil,nil)
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

public func CheckAuthority (client: Beowulf.Client, account: String, subAcc: String) -> Bool{
    let acc = GetAccounts(client: client, accounts: [account])
    if acc == nil{
        return false
    }
    if acc!.count == 0{
        return false
    }
    let superAcc = acc![0]
    let accAuths = superAcc.owner.accountAuths
    let subAccAuth = Authority.Auth(subAcc, weight: 1)
    if accAuths.count > 0{
        if accAuths.contains(subAccAuth){
            return true
        }
    }
    let keyAuths = superAcc.owner.keyAuths
    if keyAuths.count > 0{
        //Get account of subAcc
        let sub = GetAccounts(client: client, accounts: [subAcc])
        if sub == nil{
            return false
        }
        if sub!.count == 0{
            return false
        }
        let subKeyAuths = sub![0].owner.keyAuths
        if subKeyAuths.count > 0{
            for item in subKeyAuths{
                let publicKey = item.value
                let keyAuth = Authority.Auth(publicKey, weight: 1)
                if keyAuths.contains(keyAuth){
                    return true
                }
            }
        }
    }
    return false
}
