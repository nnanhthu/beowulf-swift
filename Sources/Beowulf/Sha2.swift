/// Sha2 bindings.

import Crypto
import Foundation

public extension Data {
    /// Return a SHA2-256 hash of the data.
    public func sha256Digest() -> Data {
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        self.withUnsafeBytes {
            hasher_Raw(HASHER_SHA2, $0, self.count, buf)
        }
        return Data(bytesNoCopy: buf, count: 32, deallocator: .custom({ ptr, _ in
            ptr.deallocate()
        }))
    }
}
