//
//  File.swift
//  
//
//  Created by Thu on 4/27/20.
//

import Foundation

public func GetBlock(client: Beowulf.Client, blockNum: UInt32) -> SignedBlock?{
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
