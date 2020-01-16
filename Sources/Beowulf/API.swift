/// Beowulf RPC requests and responses.

import Foundation

/// Beowulf RPC API request- and response-types.
public struct API {
    /// Wrapper for pre-appbase beowulfd calls.
    public struct CallParams<T: Encodable>: Encodable {
        let api: String
        let method: String
        let params: [T]
        init(_ api: String, _ method: String, _ params: [T]) {
            self.api = api
            self.method = method
            self.params = params
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(api)
            try container.encode(method)
            try container.encode(params)
        }
    }

    public struct DynamicGlobalProperties: Decodable {
               
        public let jsonrpc: String
        public let result: DynamicGlobalProperties2
        public let id: Int
        }
    
    public struct DynamicGlobalProperties2: Decodable {
//       	public let id: Data
        public let headBlockNumber: UInt32
        public let headBlockId: BlockId
        public let time: Date
        public let currentSupernode: String
        public let currentSupply: Asset
        public let currentWdSupply: Asset
        public let totalVestingFund: Asset
        public let totalVestingShares: Asset
        public let currentAslot: UInt64
        public let recentSlotsFilled: Int64
        public let participationCount: UInt8
        public let lastIrreversibleBlockNum: UInt32
    }

    public struct GetDynamicGlobalProperties: Request {
        public typealias Response = DynamicGlobalProperties
        public let method = "condenser_api.get_dynamic_global_properties"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
        
//        public typealias Response = DynamicGlobalProperties
//        public let method = "condenser_api.get_dynamic_global_properties"
//        public let params: RequestParams<Int>?
//        public init() {
//            self.params = RequestParams([])
//        }
    }

    public struct TransactionConfirmation: Decodable {
        public let id: Data
        public let blockNum: Int32
        public let trxNum: Int32
        public let expired: Bool
        public let createdTime: Int64
    }

    public struct AsyncTransactionConfirmation: Decodable {
            public let id: Data
    }

    public struct BroadcastTransaction: Request {
        public typealias Response = TransactionConfirmation
        public let method = "call"
        public let params: CallParams<SignedTransaction>?
        public init(transaction: SignedTransaction) {
            self.params = CallParams("condenser_api", "broadcast_transaction_synchronous", [transaction])
        }
    }

    public struct BroadcastTransactionAsync: Request {
        public typealias Response = AsyncTransactionConfirmation
        public let method = "call"
        public let params: CallParams<SignedTransaction>?
        public init(transaction: SignedTransaction) {
            self.params = CallParams("condenser_api", "broadcast_transaction", [transaction])
        }
    }

    public struct GetBlock: Request {
        public typealias Response = SignedBlock
        public let method = "get_block"
        public let params: RequestParams<Int>?
        public init(blockNum: Int) {
            self.params = RequestParams([blockNum])
        }
    }

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
        public let id: UInt16
        public let name: String
        public let owner: Authority
        public let jsonMetadata: String
        public let lastOwnerUpdate: Date
        public let lastAccountUpdate: Date
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
        public let vestingBalance: String
        public let supernodeVotes: [String]
    }

    /// Fetch accounts.
    public struct GetAccounts: Request {
        public typealias Response = [ExtendedAccount]
        public let method = "get_accounts"
        public let params: RequestParams<[String]>?
        public init(names: [String]) {
            self.params = RequestParams([names])
        }
    }
}
