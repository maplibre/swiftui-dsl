import CommonCrypto
import Foundation
import MapLibre

// DISCUSS: Is this the best way to do this?
/// Generic function that copies a struct and operates on the modified value.
///
/// Declarative DSLs frequently use this pattern in Swift (think Views in SwiftUI), but there is no
/// generic way to do this at the language level.
public func modified<T>(_ value: T, using modifier: (inout T) -> Void) -> T {
    var copy = value
    modifier(&copy)
    return copy
}

/// Adds a source to the style if a source with the given
/// ID does not already exist. Returns the source
/// on the map for the given ID.
public func addSourceIfNecessary(_ source: MLNSource, to mlnStyle: MLNStyle) -> MLNSource {
    if let existingSource = mlnStyle.source(withIdentifier: source.identifier) {
        return existingSource
    } else {
        mlnStyle.addSource(source)
        return source
    }
}

public extension UIImage {
    /// Computes a SHA256 hash of the image data.
    ///
    /// This is used internally to generate identifiers for images that can be used in the MapLibre GL
    /// style which uniquely identify `UIImage`s to the renderer.
    func sha256() -> String {
        if let imageData = cgImage?.dataProvider?.data as? Data {
            return imageData.digest.hexString
        }
        return ""
    }
}

extension Data {
    var digest: Data {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)

        withUnsafeBytes { bufferPointer in
            let bytesPointer = bufferPointer.bindMemory(to: UInt8.self).baseAddress!

            _ = CC_SHA256(bytesPointer, CC_LONG(count), &hash)
        }

        return Data(bytes: hash, count: digestLength)
    }

    var hexString: String {
        map { String(format: "%02.2hhx", $0) }.joined()
    }
}
