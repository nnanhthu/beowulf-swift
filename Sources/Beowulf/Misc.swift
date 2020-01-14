/// Misc Beowulf protocol types.

import Foundation

/// A type that is decodable to Beowulf binary format as well as JSON encodable and decodable.
public typealias BeowulfCodable = BeowulfEncodable & Decodable

/// Placeholder type for future extensions.
public struct FutureExtensions: BeowulfCodable, Equatable {}
