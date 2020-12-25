/// Beowulf Signature implementation.

import Foundation

/// A Beowulf signature.
public struct Signature: Equatable, LosslessStringConvertible {
    private let signature: Data
    private let recoveryId: Int32

    public init(signature: Data, recoveryId: Int32) {
        self.signature = signature
        self.recoveryId = recoveryId
    }

    /// Create a new signature from a byte buffer.
    /// - Parameter data: The 65-byte signature.
    public init?(_ data: Data) {
        guard data.count == 65 else {
            return nil
        }
        print("signature: \(data.suffix(from: 1))")
        print("recoveryId: \(data[0])")
        self.init(signature: data.suffix(from: 1), recoveryId: Int32(data[0]) - 31)
    }

    /// Create a new signature from a hex encoded string.
    /// - Parameter hex: The 65-byte hex string.
    public init?(_ hex: String) {
        self.init(Data(hexEncoded: hex))
    }

    /// Recover public key used to sign the message.
    /// - Parameter message: The 32-byte message that was signed.
    /// - Parameter prefix: The address prefix to use for the resulting public key, optional.
    /// - Returns: The public key used to create the signature or nil if the recovery was unsucessful.
    public func recover(message: Data, prefix: PublicKey.AddressPrefix = .mainNet) -> PublicKey? {
        guard let key = try? Secp256k1Context.shared.recover(message: message, signature: self.signature, recoveryId: Int32(self.recoveryId)) else {
            return nil
        }
        return PublicKey(key: key, prefix: prefix)!
    }

    /// Hex string representation of signature.
    public var description: String {
        var data = self.signature
        data.insert(UInt8(self.recoveryId + 31), at: data.startIndex)
        return data.hexEncodedString()
    }
}

// Codable conformance.
public extension Signature: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let signature = Signature(try container.decode(String.self)) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid signature")
        }
        self = signature
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(self))
    }
}
