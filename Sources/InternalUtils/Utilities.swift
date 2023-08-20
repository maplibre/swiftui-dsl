import Foundation
import Mapbox

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

// TODO: Figure out if this is what we want behavior-wise.
/// Adds a source to the style if a source with the given
/// ID does not already exist. Returns the source
/// on the map for the given ID.
public func addSource(_ source: MGLSource, to mglStyle: MGLStyle) -> MGLSource {
    if let existingSource = mglStyle.source(withIdentifier: source.identifier) {
        return existingSource
    } else {
        mglStyle.addSource(source)
        return source
    }
}
