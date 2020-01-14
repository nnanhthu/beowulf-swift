/// Beowulf operation types.

import Foundation

/// A type that represents a operation on the Beowulf blockchain.
public protocol OperationType: BeowulfCodable {}

/// Namespace for all available Beowulf operations.
public struct Operation {

    /// Transfers assets from one account to another.
    public struct Transfer: OperationType, Equatable {
        /// Account name of the sender.
        public var from: String
        /// Account name of the reciever.
        public var to: String
        /// Amount to transfer.
        public var amount: Asset
        /// Fee to transfer.
        public var fee: Asset
        /// Note attached to transaction.
        public var memo: String

        public init(from: String, to: String, amount: Asset, fee: Asset, memo: String = "") {
            self.from = from
            self.to = to
            self.amount = amount
            self.fee = fee
            self.memo = memo
        }
    }

    /// Converts BWF to VESTS, aka. "Powering Up".
    public struct TransferToVesting: OperationType, Equatable {
        /// Account name of sender.
        public var from: String
        /// Account name of reciever.
        public var to: String
        /// Amount to power up, must be BWF.
        public var amount: Asset
        /// Fee to power up, must be W.
        public var fee: Asset

        public init(from: String, to: String, amount: Asset, fee: Asset) {
            self.from = from
            self.to = to
            self.amount = amount
            self.fee = fee
        }
    }

    /// Starts a vesting withdrawal, aka. "Powering Down".
    public struct WithdrawVesting: OperationType, Equatable {
        /// Account that is powering down.
        public var account: String
        /// Amount that is powered down, must be VESTS.
        public var vestingShares: Asset
        /// Fee to power down, must be W.
        public var fee: Asset

        public init(account: String, vestingShares: Asset, fee: Asset) {
            self.account = account
            self.vestingShares = vestingShares
            self.fee = fee
        }
    }

    /// Creates a new account.
    public struct AccountCreate: OperationType, Equatable {
        public var fee: Asset
        public var creator: String
        public var newAccountName: String
        public var owner: Authority
        public var jsonMetadata: String

        public init(
            fee: Asset,
            creator: String,
            newAccountName: String,
            owner: Authority,
            jsonMetadata: String = ""
        ) {
            self.fee = fee
            self.creator = creator
            self.newAccountName = newAccountName
            self.owner = owner
            self.jsonMetadata = jsonMetadata
        }

        /// Account metadata.
        var metadata: [String: Any]? {
            set { self.jsonMetadata = encodeMeta(newValue) }
            get { return decodeMeta(self.jsonMetadata) }
        }
    }

    /// Updates an account.
    public struct AccountUpdate: OperationType, Equatable {
        public var account: String
        public var owner: Authority?
        public var fee: Asset
        public var jsonMetadata: String

        public init(
            account: String,
            owner: Authority?,
            fee: Asset,
            jsonMetadata: String = ""
        ) {
            self.account = account
            self.owner = owner
            self.fee = fee
            self.jsonMetadata = jsonMetadata
        }
    }

    /// Registers or updates supernodes.
    public struct SupernodeUpdate: OperationType, Equatable {
        public var owner: String
        public var blockSigningKey: PublicKey
        public var fee: Asset

        public init(
            owner: String,
            blockSigningKey: PublicKey,
            fee: Asset
        ) {
            self.owner = owner
            self.blockSigningKey = blockSigningKey
            self.fee = fee
        }
    }

    /// Votes for a supernode.
    public struct AccountSupernodeVote: OperationType, Equatable {
        public var account: String
        public var supernode: String
        public var approve: Bool
        public var votes: Int64
        public var fee: Asset

        public init(account: String, supernode: String, approve: Bool, votes: Int64, fee: Asset) {
            self.account = account
            self.supernode = supernode
            self.approve = approve
            self.votes = votes
            self.fee = fee
        }
    }

    /// Unknown operation, seen if the decoder encounters operation which has no type defined.
    /// - Note: Not encodable, the encoder will throw if encountering this operation.
    public struct Unknown: OperationType, Equatable {}
}

// MARK: - Encoding

/// Operation ID, used for coding.
fileprivate enum OperationId: UInt8, BeowulfEncodable, Decodable {
    case transfer = 0
    case transfer_to_vesting = 1
    case withdraw_vesting = 2
    case account_create = 3
    case account_update = 4
    case supernode_update = 5
    case account_supernode_vote = 6
    case unknown = 255

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let name = try container.decode(String.self)
        switch name {
        case "transfer": self = .transfer
        case "transfer_to_vesting": self = .transfer_to_vesting
        case "withdraw_vesting": self = .withdraw_vesting
        case "account_create": self = .account_create
        case "account_update": self = .account_update
        case "supernode_update": self = .supernode_update
        case "account_supernode_vote": self = .account_supernode_vote
        default: self = .unknown
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(self)")
    }

    func binaryEncode(to encoder: BeowulfEncoder) throws {
        try encoder.encode(self.rawValue)
    }
}

/// A type-erased Beowulf operation.
internal struct AnyOperation: BeowulfEncodable, Decodable {
    public let operation: OperationType

    /// Create a new operation wrapper.
    public init<O>(_ operation: O) where O: OperationType {
        self.operation = operation
    }

    public init(_ operation: OperationType) {
        self.operation = operation
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let id = try container.decode(OperationId.self)
        let op: OperationType
        switch id {
        case .transfer: op = try container.decode(Operation.Transfer.self)
        case .transfer_to_vesting: op = try container.decode(Operation.TransferToVesting.self)
        case .withdraw_vesting: op = try container.decode(Operation.WithdrawVesting.self)
        case .account_create: op = try container.decode(Operation.AccountCreate.self)
        case .account_update: op = try container.decode(Operation.AccountUpdate.self)
        case .supernode_update: op = try container.decode(Operation.SupernodeUpdate.self)
        case .account_supernode_vote: op = try container.decode(Operation.AccountSupernodeVote.self)
        case .unknown: op = Operation.Unknown()
        }
        self.operation = op
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self.operation {
        case let op as Operation.Transfer:
            try container.encode(OperationId.transfer)
            try container.encode(op)
        case let op as Operation.TransferToVesting:
            try container.encode(OperationId.transfer_to_vesting)
            try container.encode(op)
        case let op as Operation.WithdrawVesting:
            try container.encode(OperationId.withdraw_vesting)
            try container.encode(op)
        case let op as Operation.AccountCreate:
            try container.encode(OperationId.account_create)
            try container.encode(op)
        case let op as Operation.AccountUpdate:
            try container.encode(OperationId.account_update)
            try container.encode(op)
        case let op as Operation.SupernodeUpdate:
            try container.encode(OperationId.supernode_update)
            try container.encode(op)
        case let op as Operation.AccountSupernodeVote:
            try container.encode(OperationId.account_supernode_vote)
            try container.encode(op)
        default:
            throw EncodingError.invalidValue(self.operation, EncodingError.Context(
                codingPath: container.codingPath, debugDescription: "Encountered unknown operation type"))
        }
    }
}


fileprivate func encodeMeta(_ value: [String: Any]?) -> String {
    if let object = value,
        let encoded = try? JSONSerialization.data(withJSONObject: object, options: []) {
        return String(bytes: encoded, encoding: .utf8) ?? ""
    } else {
        return ""
    }
}

fileprivate func decodeMeta(_ value: String) -> [String: Any]? {
    guard let data = value.data(using: .utf8) else {
        return nil
    }
    let decoded = try? JSONSerialization.jsonObject(with: data, options: [])
    return decoded as? [String: Any]
}
