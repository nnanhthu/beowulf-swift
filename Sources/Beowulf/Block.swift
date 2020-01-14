/// Beowulf block types.

import Foundation

/// Type representing a Beowulf block ID.
public struct BlockId: Codable, Equatable {
    /// The block hash.
    public var hash: Data
    /// The block number.
    public var num: UInt32 {
        return UInt32(bigEndian: self.hash.withUnsafeBytes { $0.pointee })
    }

    /// The block prefix.
    public var prefix: UInt32 {
        return UInt32(littleEndian: self.hash.suffix(from: 4).withUnsafeBytes { $0.pointee })
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.hash = try container.decode(Data.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.hash)
    }
}

/// Block extensions used for signaling.
public enum BlockExtension: Equatable {
    /// Unknown block extension.
    case unknown
    /// Supernode version reporting.
    case version(String)
    /// Supernode hardfork vote.
    case hardforkVersionVote(String, Date)
}

/// Internal protocol for a block header.
fileprivate protocol _BlockHeader: Codable {
    /// The block id of the block preceding this one.
    var previous: BlockId { get }
    /// Time when block was generated.
    var timestamp: Date { get }
    /// Supernode who produced it.
    var supernode: String { get }
    /// Merkle root hash, ripemd160.
    var transactionMerkleRoot: Data { get }
    /// Block reward
    var blockReward: Asset { get }
    /// Block extensions.
    var extensions: [BlockExtension] { get }
}

/// A type representing a Beowulf block header.
public struct BlockHeader: _BlockHeader {
    public let previous: BlockId
    public let timestamp: Date
    public let supernode: String
    public let transactionMerkleRoot: Data
    public let blockReward: Asset
    public let extensions: [BlockExtension]
}

/// A type representing a signed Beowulf block header.
public struct SignedBlockHeader: _BlockHeader, Equatable {
    public let previous: BlockId
    public let timestamp: Date
    public let supernode: String
    public let transactionMerkleRoot: Data
    public let blockReward: Asset
    public let extensions: [BlockExtension]
    public let supernodeSignature: Signature
}

/// A type representing a Beowulf block.
public struct SignedBlock: _BlockHeader, Equatable {
    /// The transactions included in this block.
    public let transactions: [Transaction]
    /// The block number.
    public var num: UInt32 {
        return self.header.previous.num + 1
    }

    private let header: SignedBlockHeader

    /// Create a new Signed block.
    public init(header: SignedBlockHeader, transactions: [Transaction]) {
        self.header = header
        self.transactions = transactions
    }

    // Header proxy.
    public var previous: BlockId { return self.header.previous }
    public var timestamp: Date { return self.header.timestamp }
    public var supernode: String { return self.header.supernode }
    public var transactionMerkleRoot: Data { return self.header.transactionMerkleRoot }
    public var blockReward: Asset {return self.header.blockReward }
    public var extensions: [BlockExtension] { return self.header.extensions }
    public var supernodeSignature: Signature { return self.header.supernodeSignature }

    private enum Key: CodingKey {
        case transactions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.transactions = try container.decode([Transaction].self, forKey: .transactions)
        self.header = try SignedBlockHeader(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try self.header.encode(to: encoder)
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.transactions, forKey: .transactions)
    }
}

extension BlockExtension: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let type = try container.decode(Int.self)
        switch type {
        case 1:
            self = .version(try container.decode(String.self))
        default:
            self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self {
        case let .version(version):
            try container.encode(1 as Int)
            try container.encode(version)
        default:
            break
        }
    }
}
