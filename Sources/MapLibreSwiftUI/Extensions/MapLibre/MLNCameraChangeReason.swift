import Foundation
import MapLibre

extension MLNCameraChangeReason {
    
    /// Get the last value from the MLNCameraChangeReason option set.
    public var lastValue: MLNCameraChangeReason {
        // Start at 1
        var mask: UInt = 1
        var result: UInt = 0
        
        while mask <= self.rawValue {
            // If the raw value matches the remaining mask.
            if self.rawValue & mask != 0 {
                result = mask
            }
            // Shift all the way until the rawValue has been allocated and we have the true last value.
            mask <<= 1
        }
        
        return MLNCameraChangeReason(rawValue: result)
    }
}
