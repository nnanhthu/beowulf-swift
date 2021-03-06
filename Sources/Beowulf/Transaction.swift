/// Beowulf transaction type.

import AnyCodable
import Foundation

public struct ExtensionJsonType: Codable {
    public var data: String
    public init?(){
        self.data = ""
    }
    public enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

public struct ExtensionType: Codable{
    public var type: UInt8
    public var value: ExtensionJsonType?
    public init?(){
        self.type = 1
        self.value = ExtensionJsonType()
    }
    public enum CodingKeys: String, CodingKey {
        case type = "type"
        case value = "value"
    }
}

fileprivate protocol _Transaction: BeowulfEncodable, Decodable {
    /// Block number reference.
    var refBlockNum: UInt16 { get }
    /// Block number reference id.
    var refBlockPrefix: UInt32 { get }
    /// Transaction expiration.
    var expiration: Date { get }
    /// Protocol extensions.
    var extensions: [ExtensionType] { get }
    /// Transaction operations.
    var operations: [OperationType] { get }
    /// Transaction created time
    var createdTime: UInt64 { get }
    /// SHA2-256 digest for signing.
    func digest(forChain chain: ChainId) throws -> Data
}

public struct Transaction: _Transaction {
    public var refBlockNum: UInt16
    public var refBlockPrefix: UInt32
    public var expiration: Date
    public var extensions: [ExtensionType]
    public var operations: [OperationType] {
        return self._operations.map { $0.operation }
    }
    public var createdTime: UInt64

    internal var _operations: [AnyOperation]

    /// Create a new transaction.
public init(refBlockNum: UInt16, refBlockPrefix: UInt32, expiration: Date, createdTime: UInt64, operations: [OperationType] = [], extensions: [ExtensionType] = []) {
        self.refBlockNum = refBlockNum
        self.refBlockPrefix = refBlockPrefix
        self.expiration = expiration
        self._operations = operations.map { AnyOperation($0) }
        self.extensions = extensions
        self.createdTime = createdTime
    }

    /// Append an operation to the transaction.
    public mutating func append(operation: OperationType) {
        self._operations.append(AnyOperation(operation))
    }

    /// Sign transaction.
    public func sign(usingKey key: [PrivateKey], forChain chain: ChainId = .mainNet) throws -> SignedTransaction {
        var signed = SignedTransaction(transaction: self)
        for pk in key{
            try signed.appendSignature(usingKey: pk, forChain: chain)
        }
        return signed
    }

    /// SHA2-256 digest for signing.
    public func digest(forChain chain: ChainId = .mainNet) throws -> Data {
        var data = chain.data
        data.append(try BeowulfEncoder.encode(self))
//        var data = try BeowulfEncoder.encode(self)
        print(data.sha256Digest())
        return data.sha256Digest()
    }
}

extension Transaction: Equatable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return (try? lhs.digest()) == (try? rhs.digest())
    }
}

/// A signed transaction.
public struct SignedTransaction: _Transaction, Equatable {
    /// Transaction signatures.
    public var signatures: [Signature]

    private var transaction: Transaction

    /// Create a new signed transaction.
    /// - Parameter transaction: Transaction to wrap.
    /// - Parameter signatures: Transaction signatures.
    public init(transaction: Transaction, signatures: [Signature] = []) {
        self.transaction = transaction
        self.signatures = signatures
    }

    /// Append a signature to the transaction.
    public mutating func appendSignature(_ signature: Signature) {
        self.signatures.append(signature)
    }

    /// Sign transaction and append signature.
    /// - Parameter key: Private key to sign transaction with.
    /// - Parameter chain: Chain id to use when signing.
    public mutating func appendSignature(usingKey key: PrivateKey, forChain chain: ChainId = .mainNet) throws {
        let signature = try key.sign(message: self.transaction.digest(forChain: chain))
        signatures.append(signature)
    }

    // Transaction proxy.

    public var refBlockNum: UInt16 {
        return self.transaction.refBlockNum
    }

    public var refBlockPrefix: UInt32 {
        return self.transaction.refBlockPrefix
    }

    public var expiration: Date {
        return self.transaction.expiration
    }

    public var extensions: [ExtensionType] {
        return self.transaction.extensions
    }

    public var operations: [OperationType] {
        return self.transaction.operations
    }

    public var createdTime: UInt64 {
            return self.transaction.createdTime
    }

    public func digest(forChain chain: ChainId = .mainNet) throws -> Data {
        return try self.transaction.digest(forChain: chain)
    }
}

/// A signed transaction.
public struct TransactionResponse: _Transaction {
    public var refBlockNum: UInt16
    public var refBlockPrefix: UInt32
    public var expiration: Date
    public var extensions: [ExtensionType]
    public var operations: [OperationType] {
        return self._operations.map { $0.operation }
    }
    public var signatures: [String]
    public var createdTime: UInt64
    public var transactionId: String
    public var blockNum: UInt32
    public var transactionNum: UInt32
    public var status: String

    internal var _operations: [AnyOperation]

    /// Create a new transaction.
//public init(refBlockNum: UInt16, refBlockPrefix: UInt32, expiration: Date, createdTime: UInt64, operations: [OperationType] = [], extensions: [String] = []) {
//        self.refBlockNum = refBlockNum
//        self.refBlockPrefix = refBlockPrefix
//        self.expiration = expiration
//        self._operations = operations.map { AnyOperation($0) }
//        self.extensions = extensions
//        self.createdTime = createdTime
//    }

    /// Append an operation to the transaction.
    public mutating func append(operation: OperationType) {
        self._operations.append(AnyOperation(operation))
    }

    /// SHA2-256 digest for signing.
    public func digest(forChain chain: ChainId = .mainNet) throws -> Data {
        var data = chain.data
        data.append(try BeowulfEncoder.encode(self))
        return data.sha256Digest()
    }
}

extension TransactionResponse: Equatable {
    public static func == (lhs: TransactionResponse, rhs: TransactionResponse) -> Bool {
        return (try? lhs.digest()) == (try? rhs.digest())
    }
}

// Codable conformance.
public extension TransactionResponse {
    fileprivate enum Key: CodingKey {
        case refBlockNum
        case refBlockPrefix
        case expiration
        case operations
        case extensions
        case createdTime
        case transactionId
        case blockNum
        case transactionNum
        case status
        case signatures
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.refBlockNum = try container.decode(UInt16.self, forKey: .refBlockNum)
        self.refBlockPrefix = try container.decode(UInt32.self, forKey: .refBlockPrefix)
        self.expiration = try container.decode(Date.self, forKey: .expiration)
        self._operations = try container.decode([AnyOperation].self, forKey: .operations)
        self.extensions = try container.decode([ExtensionType].self, forKey: .extensions)
        self.createdTime = try container.decode(UInt64.self, forKey: .createdTime)
        self.signatures = try container.decode([String].self, forKey: .signatures)
        self.transactionId = try container.decode(String.self, forKey: .transactionId)
        self.blockNum = try container.decode(UInt32.self, forKey: .blockNum)
        self.transactionNum = try container.decode(UInt32.self, forKey: .transactionNum)
        self.status = try container.decode(String.self, forKey: .status)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.refBlockNum, forKey: .refBlockNum)
        try container.encode(self.refBlockPrefix, forKey: .refBlockPrefix)
        try container.encode(self.expiration, forKey: .expiration)
        try container.encode(self._operations, forKey: .operations)
        try container.encode(self.extensions, forKey: .extensions)
        try container.encode(self.createdTime, forKey: .createdTime)
        try container.encode(self.signatures, forKey: .signatures)
        try container.encode(self.transactionId, forKey: .transactionId)
        try container.encode(self.blockNum, forKey: .blockNum)
        try container.encode(self.transactionNum, forKey: .transactionNum)
        try container.encode(self.status, forKey: .status)
    }
}

public extension Transaction {
    fileprivate enum Key: CodingKey {
        case refBlockNum
        case refBlockPrefix
        case expiration
        case operations
        case extensions
        case createdTime
        case signatures
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.refBlockNum = try container.decode(UInt16.self, forKey: .refBlockNum)
        self.refBlockPrefix = try container.decode(UInt32.self, forKey: .refBlockPrefix)
        self.expiration = try container.decode(Date.self, forKey: .expiration)
        self._operations = try container.decode([AnyOperation].self, forKey: .operations)
        self.extensions = try container.decode([ExtensionType].self, forKey: .extensions)
        self.createdTime = try container.decode(UInt64.self, forKey: .createdTime)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.refBlockNum, forKey: .refBlockNum)
        try container.encode(self.refBlockPrefix, forKey: .refBlockPrefix)
        try container.encode(self.expiration, forKey: .expiration)
        try container.encode(self._operations, forKey: .operations)
        try container.encode(self.extensions, forKey: .extensions)
        try container.encode(self.createdTime, forKey: .createdTime)
    }
}

public extension SignedTransaction {
    private enum Key: CodingKey {
        case signatures
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.signatures = try container.decode([Signature].self, forKey: .signatures)
        self.transaction = try Transaction(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try self.transaction.encode(to: encoder)
        try container.encode(self.signatures, forKey: .signatures)
    }
}

// Workaround for: Swift runtime does not yet support dynamically querying conditional conformance.
#if !swift(>=4.2)
    public extension Transaction {
        public func binaryEncode(to encoder: BeowulfEncoder) throws {
            try encoder.encode(self.refBlockNum)
            try encoder.encode(self.refBlockPrefix)
            try encoder.encode(self.expiration)
            encoder.appendVarint(UInt64(self.operations.count))
            for operation in self._operations {
                try operation.binaryEncode(to: encoder)
            }
            if self.extensions.count > 0{
                encoder.appendVarint(UInt64(self.extensions.count))
                for ext in self.extensions {
//                    ext.binaryEncode(to: encoder)
                    try encoder.encode(ext)
                }
            }else{
                encoder.appendVarint(0)
            }
            try encoder.encode(self.createdTime)
        }
    }
#endif
