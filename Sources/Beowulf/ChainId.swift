/// Beowulf chain identifiers.

import Foundation

/// Chain id, used to sign transactions.
public enum ChainId: Equatable {
    /// The main Beowulf network.
    case mainNet
    /// Defualt testing network id.
    case testNet
    /// Custom chain id.
    case custom(Data)
}

fileprivate let mainNetId = Data(hexEncoded: "e2222eeabcf9224632c82ec86ba3d77b359e3b5cb8a089ddd45090c31c98e3f2")
fileprivate let testNetId = Data(hexEncoded: "430b37f23cf146d42f15376f341d7f8f5a1ad6f4e63affdeb5dc61d55d8c95a7")

extension ChainId {
    /// The 32-byte chain id.
    public var data: Data {
        switch self {
        case .mainNet:
            return mainNetId
        case .testNet:
            return testNetId
        case let .custom(id):
            return id
        }
    }
}
