import Foundation
import MapLibre

public extension MLNCameraChangeReason {
    /// Get the MLNCameraChangeReason from the option set with the largest
    /// bitwise value.
    var largestBitwiseReason: MLNCameraChangeReason {
        // Start at 1
        var mask: UInt = 1
        var result: UInt = 0

        while mask <= rawValue {
            // If the raw value matches the remaining mask.
            if rawValue & mask != 0 {
                result = mask
            }
            // Shift all the way until the rawValue has been allocated and we have the true last value.
            mask <<= 1
        }

        return MLNCameraChangeReason(rawValue: result)
    }
}
