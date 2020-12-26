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

//    public struct DynamicGlobalProperties: Decodable {
//
//        public let jsonrpc: String
//        public let result: DynamicGlobalProperties2
//        public let id: Int
//        }
    
    public struct DynamicGlobalProperties: Codable, Equatable {
//       	public let id: Data
        public let headBlockNumber: UInt32
        public let headBlockId: BlockId
        public let time: Date
        public let currentSupernode: String
        public let currentSupply: Asset
        public let currentWdSupply: Asset
        public let totalVestingFundBeowulf: Asset
        public let totalVestingShares: Asset
        public let currentAslot: UInt64
//        public let recentSlotsFilled: String
//        public let participationCount: UInt8
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
        public let method = "condenser_api.get_block"
        public let params: RequestParams<Int>?
        public init(blockNum: Int) {
            self.params = RequestParams([blockNum])
        }
    }
    
    public struct GetBlockHeader: Request {
        public typealias Response = BlockHeader
        public let method = "condenser_api.get_block_header"
        public let params: RequestParams<Int>?
        public init(blockNum: Int) {
            self.params = RequestParams([blockNum])
        }
    }
    
    /// Fetch accounts.
    public struct GetAccounts: Request {
        public typealias Response = [ExtendedAccount]
        public let method = "condenser_api.get_accounts"
        public let params: RequestParams<[String]>?
        public init(names: [String]) {
            self.params = RequestParams([names])
        }
    }
    
    ///GetVersion of chain
    public struct Version: Codable, Equatable{
        public let blockchainVersion: String
        public let beowulfRevision: String
        public let fcRevision: String
    }
    public struct GetVersion: Request {
        public typealias Response = Version
        public let method = "condenser_api.get_version"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    
    /// GetConfig
    public struct Config: Codable, Equatable{
        public let isTestNet: Bool
        public let smtTokenCreationFee: Int
//        public let wdSymbol: Asset.Symbol
        public let beowulf100Percent: Int
        public let beowulf1Percent: Int
        public let beowulfAddressPrefix: String
        public let beowulfBlockchainHardforkVersion: String
        public let beowulfBlockchainVersion: String
        public let beowulfBlockInterval: UInt
        public let beowulfBlocksPerDay: Int
        public let beowulfBlocksPerYear: Int
        public let beowulfChainId: String
        public let beowulfGenesisTime: Date
        public let beowulfHardforkRequiredSupernodes: Int
        public let beowulfInflationNarrowingPeriod: Int
        public let beowulfInflationRateStartPercent: Int
        public let beowulfInflationRateStopPercent: Int
        public let beowulfInitMinerName: String
        public let beowulfInitPublicKeyStr: String
        public let beowulfInitSupply: Int
        public let wdInitSupply: Int
        public let beowulfIrreversibleThreshold: Int
        public let beowulfMaxAccountNameLength: Int
        public let beowulfMaxAccountSupernodeVotes: Int
        public let beowulfMaxAuthorityMembership: Int
        public let beowulfSoftMaxBlockSize: Int
        public let beowulfMaxMemoSize: Int
        public let beowulfMaxSupernodes: Int
        public let beowulfMaxPermanentSupernodesHf0: Int
        public let beowulfMaxRunnerSupernodesHf0: Int
        public let beowulfMaxShareSupply: Int
        public let beowulfMaxSigCheckDepth: Int
        public let beowulfMaxSigCheckAccounts: Int
        public let beowulfMaxTimeUntilExpiration: Int
        public let beowulfMaxTransactionSize: Int
        public let beowulfMaxUndoHistory: Int
        public let beowulfMaxVotedSupernodesHf0: Int
        public let beowulfMinSupernodeFund: Int
        public let beowulfMinTransactionFee: Int
        public let beowulfMinAccountCreationFee: Int
        public let beowulfMinAccountNameLength: Int
        public let beowulfMinBlockSize: Int
        public let beowulfNullAccount: String
        public let beowulfNumInitMiners: Int
        public let beowulfOwnerAuthHistoryTrackingStartBlockNum: Int
        public let beowulfOwnerUpdateLimit: Int
        public let beowulfVestingWithdrawIntervals: Int
        public let beowulfVestingWithdrawIntervalSeconds: Int
        //beowulfSYMBOL
        //VESTSSYMBOL
        public let beowulfVirtualScheduleLapLength2: String
        public let beowulf1Beowulf: Int
        public let beowulf1Vests: Int
        public let beowulfMaxTokenPerAccount: Int
        public let beowulfMinPermanentSupernodeFund: Int
        public let beowulfMaxTokenNameLength: Int
        public let beowulfMinTokenNameLength: Int
        public let beowulfSymbolBeowulf: String
        public let beowulfSymbolWd: String
        public let beowulfSymbolVests: String
        public let beowulfBlockRewardGap: Int
        public let beowulfItemQueueSize: Int
        public let beowulfFlushInterval: Int
    }
    public struct GetConfig: Request {
        public typealias Response = Config
        public let method = "condenser_api.get_config"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    
    public struct SupernodeSchedule: Codable, Equatable{
        public let id: UInt16
        public let currentVirtualTime: String
        public let nextShuffleBlockNum: UInt32
        public let currentShuffledSupernodes: [String]
        public let numScheduledSupernodes: UInt8
        public let electedWeight: UInt8
        public let timeshareWeight: UInt8
        public let permanentWeight: UInt8
        public let supernodePayNormalizationFactor: UInt32
        public let majorityVersion: String
        public let maxVotedSupernodes:UInt8
        public let maxPermanentSupernodes:UInt8
        public let maxRunnerSupernodes: UInt8
        public let hardforkRequiredSupernodes: UInt8
    }
    public struct GetSupernodeSchedule: Request {
        public typealias Response = SupernodeSchedule
        public let method = "condenser_api.get_supernode_schedule"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    
    public struct GetHardforkVersion: Request {
        public typealias Response = String
        public let method = "condenser_api.get_hardfork_version"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    
    public struct ScheduledHardfork: Codable, Equatable{
        public let hfVersion: String
        public let liveTime: Date
    }
    public struct GetNextScheduleHardfork: Request {
        public typealias Response = ScheduledHardfork
        public let method = "condenser_api.get_next_scheduled_hardfork"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    public struct GetTransaction: Request {
        public typealias Response = TransactionResponse
        public let method = "condenser_api.get_transaction"
        public let params: RequestParams<String>?
        public init(txId: String) {
            self.params = RequestParams([txId])
        }
    }
    public struct GetTransactionWithStatus: Request {
        public typealias Response = TransactionResponse
        public let method = "condenser_api.get_transaction_with_status"
        public let params: RequestParams<String>?
        public init(txId: String) {
            self.params = RequestParams([txId])
        }
    }
    public struct GetTransactionHex: Request {
        public typealias Response = String
        public let method = "condenser_api.get_transaction_hex"
        public let params: RequestParams<Transaction>?
        public init(tx: Transaction) {
            self.params = RequestParams([tx])
        }
    }
    
    public struct SupernodeInfo: Codable, Equatable{
        public let id: UInt16
        public let owner: String
        public let created: Date
        public let totalMissed: UInt32
        public let lastAslot: UInt64
        public let lastConfirmedBlockNum: UInt64
        public let signingKey: String
        public let votes: Int64
        public let lastWork: String
        public let runningVersion: String
        public let hardforkVersionVote: String
        public let hardforkTimeVote: Date
    }
    public struct GetSupernodes: Request {
        public typealias Response = [SupernodeInfo]
        public let method = "condenser_api.get_supernodes"
        public let params: RequestParams<[UInt16]>?
        public init(ids: [UInt16]) {
            self.params = RequestParams([ids])
        }
    }
    public struct GetSupernodeByAccount: Request {
        public typealias Response = SupernodeInfo
        public let method = "condenser_api.get_supernode_by_account"
        public let params: RequestParams<String>?
        public init(account: String) {
            self.params = RequestParams([account])
        }
    }
    public struct GetSupernodeByVote: Request {
        public typealias Response = [SupernodeInfo]
        public let method = "condenser_api.get_supernodes_by_vote"
        public let params: RequestParams<String>?
        public init(lowerBound: String, limit: UInt32) {
            self.params = RequestParams([lowerBound,String(limit)])
        }
    }
    
    public struct LookupSupernodeAccounts: Request{
        public typealias Response = [String]
        public let method = "condenser_api.lookup_supernode_accounts"
        public let params: RequestParams<String>?
        public init(lowerBound: String, limit: UInt32) {
            self.params = RequestParams([lowerBound,String(limit)])
        }
    }
    
    public struct GetSupernodeCount: Request {
        public typealias Response = UInt64
        public let method = "condenser_api.get_supernode_count"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    
    public struct SupernodeVoteInfo: Codable, Equatable{
        public let id: UInt16
        public let supernode: String
        public let account: String
        public let votes: Int64
    }
    public struct GetSupernodeVoted: Request{
        public typealias Response = [SupernodeVoteInfo]
        public let method = "condenser_api.get_supernode_voted_by_acc"
        public let params: RequestParams<String>?
        public init(account: String) {
            self.params = RequestParams([account])
        }
    }
    public struct GetKeyReferences: Request{
           public typealias Response = [[String]]
           public let method = "condenser_api.get_key_references"
           public let params: RequestParams<[String]>?
           public init(publicKey: [String]) {
               self.params = RequestParams([publicKey])
           }
       }
    public struct ListAccounts: Request{
        public typealias Response = [String]
        public let method = "condenser_api.lookup_accounts"
        public let params: RequestParams<String>?
        public init(lowerBound: String, limit: UInt32) {
            self.params = RequestParams([lowerBound,String(limit)])
        }
    }
    public struct GetAccountCount: Request {
        public typealias Response = UInt64
        public let method = "condenser_api.get_account_count"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    public struct GetActiveSupernodes: Request {
        public typealias Response = [String]
        public let method = "condenser_api.get_active_supernodes"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    public struct ListSupernodes: Request{
        public typealias Response = [String]
        public let method = "condenser_api.lookup_supernode_accounts"
        public let params: RequestParams<String>?
        public init(lowerBound: String, limit: UInt32) {
            self.params = RequestParams([lowerBound,String(limit)])
        }
    }
    
    public struct TokenInfo: Codable, Equatable{
        public let id: UInt16
        public let liquidSymbol: Symbol
        public let controlAccount: String
        public let phase: String
        public let currentSupply: Int64
    }
    public struct ListTokens: Request {
        public typealias Response = [TokenInfo]
        public let method = "condenser_api.list_smt_tokens"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
    public struct GetTokens: Request {
        public typealias Response = [TokenInfo]
        public let method = "condenser_api.find_smt_tokens_by_name"
        public let params: RequestParams<[String]>?
        public init(name: [String]) {
            self.params = RequestParams([name])
        }
    }
    
    public struct AnyEncodable: Encodable {

        private let _encode: (Encoder) throws -> Void
        public init<T: Encodable>(_ wrapped: T) {
            _encode = wrapped.encode
        }

        public func encode(to encoder: Encoder) throws {
            try _encode(encoder)
        }
    }
    
    public struct GetBalance: Request {
        public typealias Response = String
        public let method = "condenser_api.get_balance"
        public let params: RequestParams<AnyEncodable>?
        public init(account: String, tokenName: String, decimals: UInt8) {
            let symbol = Symbol(decimals, tokenName)
            self.params = RequestParams([AnyEncodable(account),AnyEncodable(symbol)])
        }
    }
    
    public struct GetPendingTransactionCount: Request {
        public typealias Response = UInt64
        public let method = "condenser_api.get_pending_transaction_count"
        public let params: RequestParams<String>?
        public init() {self.params = RequestParams([])}
    }
}
