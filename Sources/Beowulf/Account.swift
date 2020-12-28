//
//  File.swift
//  
//
//  Created by Thu on 12/26/20.
//

import Foundation

public struct Share: Decodable {
    public let value: Int64
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int64.self) {
            self.value = intValue
        } else {
            self.value = Int64(try container.decode(String.self)) ?? 0
        }
    }
}

/// The "extended" account object returned by get_accounts.
public struct ExtendedAccount: Decodable {
    public let id: UInt64
    public let name: String
    public let owner: Authority
    public let jsonMetadata: String
    public let lastOwnerUpdate: Date
    public let created: Date
    public let balance: Asset
    public let wdBalance: Asset
    public let vestingShares: Asset
    public let vestingWithdrawRate: Asset
    public let nextVestingWithdrawal: Date
    public let withdrawn: Share
    public let toWithdraw: Share
    public let supernodesVotedFor: UInt16
    public let tokenList: [String]
    public let vestingBalance: Asset
    public let supernodeVotes: [String]
    
}

// Codable conformance.
public extension ExtendedAccount {
    fileprivate enum Key: CodingKey {
        case id
        case name
        case owner
        case jsonMetadata
        case lastOwnerUpdate
        case created
        case balance
        case wdBalance
        case vestingShares
        case vestingWithdrawRate
        case nextVestingWithdrawal
        case withdrawn
        case toWithdraw
        case supernodesVotedFor
        case tokenList
        case vestingBalance
        case supernodeVotes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.id = try container.decode(UInt64.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.owner = try container.decode(Authority.self, forKey: .owner)
        self.jsonMetadata = try container.decode(String.self, forKey: .jsonMetadata)
        self.lastOwnerUpdate = try container.decode(Date.self, forKey: .lastOwnerUpdate)
        self.created = try container.decode(Date.self, forKey: .created)
        self.balance = try container.decode(Asset.self, forKey: .balance)
        self.wdBalance = try container.decode(Asset.self, forKey: .wdBalance)
        self.vestingShares = try container.decode(Asset.self, forKey: .vestingShares)
        self.vestingWithdrawRate = try container.decode(Asset.self, forKey: .vestingWithdrawRate)
        self.nextVestingWithdrawal = try container.decode(Date.self, forKey: .nextVestingWithdrawal)
        self.withdrawn = try container.decode(Share.self, forKey: .withdrawn)
        self.toWithdraw = try container.decode(Share.self, forKey: .toWithdraw)
        self.supernodesVotedFor = try container.decode(UInt16.self, forKey: .supernodesVotedFor)
        self.tokenList = try container.decode([String].self, forKey: .tokenList)
        self.vestingBalance = try container.decode(Asset.self, forKey: .vestingBalance)
        self.supernodeVotes = try container.decode([String].self, forKey: .supernodeVotes)
    }

//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Key.self)
//        try container.encode(self.name, forKey: .name)
//        try container.encode(self.owner, forKey: .owner)
//        try container.encode(self.jsonMetadata, forKey: .jsonMetadata)
//        try container.encode(self.lastOwnerUpdate, forKey: .lastOwnerUpdate)
//        try container.encode(self.created, forKey: .created)
//        try container.encode(self.balance, forKey: .balance)
//        try container.encode(self.wdBalance, forKey: .wdBalance)
//        try container.encode(self.vestingShares, forKey: .vestingShares)
//        try container.encode(self.vestingWithdrawRate, forKey: .vestingWithdrawRate)
//        try container.encode(self.nextVestingWithdrawal, forKey: .nextVestingWithdrawal)
//        try container.encode(self.withdrawn, forKey: .withdrawn)
//        try container.encode(self.toWithdraw, forKey: .toWithdraw)
//        try container.encode(self.supernodesVotedFor, forKey: .supernodesVotedFor)
//        try container.encode(self.tokenList, forKey: .tokenList)
//        try container.encode(self.vestingBalance, forKey: .vestingBalance)
//        try container.encode(self.supernodeVotes, forKey: .supernodeVotes)
//    }
}
