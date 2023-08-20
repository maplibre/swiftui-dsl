import Foundation

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
