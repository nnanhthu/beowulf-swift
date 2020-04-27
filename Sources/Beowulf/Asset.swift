/// Beowulf token types.

import Foundation
/// The Beowulf Symbol
public struct Symbol: Codable, Equatable {
    
    /// The asset symbol.
    public var decimals: UInt8

    public var name: String

    /// Create a new `Symbol`.
    public init(_ decimals: UInt8, _ name: String) {
        self.decimals = decimals
        self.name = name
    }
    public init() {
        self.decimals = 0
        self.name = ""
    }
    public static func == (lhs: Symbol, rhs: Symbol) -> Bool {
        return (lhs.decimals == rhs.decimals && lhs.name == rhs.name)
    }
}

/// The Beowulf asset type.
public struct Asset: Equatable {
    /// Asset symbol type, containing the symbol name and precision.
//    public enum Symbol: Equatable {
//        /// The BEOWULF token.
//        case beowulf
//        /// Vesting shares.
//        case vests
//        /// Beowulf-backed dollars.
//        case wd
//        /// Custom token.
//        case custom(name: String, precision: UInt8)
//
//        /// Number of decimal points represented.
//        var precision: UInt8 {
//            switch self {
//            case .beowulf, .wd, .vests:
//                return 5
//            case let .custom(_, precision):
//                return precision
//            }
//        }
//
//        /// String representation of symbol prefix, e.g. "BWF".
//        public var name: String {
//            switch self {
//            case .beowulf:
//                return "BWF"
//            case .wd:
//                return "W"
//            case .vests:
//                return "M"
//            case let .custom(name, _):
//                return name.uppercased()
//            }
//        }
//    }

    /// The asset symbol.
    public let symbol: Symbol

    internal let amount: Int64

    /// Create a new `Asset`.
    /// - Parameter value: Amount of tokens.
    /// - Parameter symbol: Token symbol.
    public init(_ value: Double, _ symbol: Symbol) {
        self.amount = Int64(round(value * pow(10, Double(symbol.decimals))))
        self.symbol = symbol
    }

    /// Create a new `Asset` from a string representation.
    /// - Parameter value: String to parse into asset, e.g. `1.000 BWF`.
    public init?(_ value: String) {
        let parts = value.split(separator: " ")
        guard parts.count == 2 else {
            return nil
        }
        var symbol = Symbol()
        switch parts[1] {
        case "BWF":
            symbol.decimals = 5
            symbol.name = "BWF"
        case "M":
            symbol.decimals = 5
            symbol.name = "M"
        case "W":
            symbol.decimals = 5
            symbol.name = "W"
        default:
            let ap = parts[0].split(separator: ".")
            let precision: UInt8 = ap.count == 2 ? UInt8(ap[1].count) : 0
            symbol = Symbol(precision, String(parts[1]) )
        }
        guard let val = Double(parts[0]) else {
            return nil
        }
        self.init(val, symbol)
    }
}

extension Asset: LosslessStringConvertible {
    public var description: String {
        let value = Double(self.amount) / pow(10, Double(self.symbol.decimals))
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.usesGroupingSeparator = false
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = Int(self.symbol.decimals)
        formatter.maximumFractionDigits = Int(self.symbol.decimals)
        let formatted = formatter.string(from: NSNumber(value: value))!
        return "\(formatted) \(self.symbol.name)"
    }
}

extension Asset: BeowulfEncodable, Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let asset = Asset(value) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Not a valid asset string")
        }
        self = asset
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(self))
    }

    public func binaryEncode(to encoder: BeowulfEncoder) throws {
        try encoder.encode(self.amount)
        try encoder.encode(self.symbol.decimals)
        let chars = self.symbol.name.utf8
        for char in chars {
            encoder.data.append(char)
        }
        for _ in 0 ..< 7 - chars.count {
            encoder.data.append(0)
        }
    }
}
