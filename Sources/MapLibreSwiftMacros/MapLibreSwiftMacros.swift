import Foundation

/// Adds a stored property and modifiers for an attribute that can be styled using a MapLibre style expression.
///
/// Layout and paint properties may be specified using expresisons.
/// Some expressions may suppeort more types of expressions than others (ex: interpolated).
/// TODO: Figure out where these edges are.
/// TODO: Document different types
@attached(member, names: arbitrary)
public macro MLNStyleProperty<T>(_ named: String, supportsInterpolation: Bool = false) = #externalMacro(
    module: "MapLibreSwiftMacrosImpl",
    type: "MLNStylePropertyMacro"
)

// NOTE: This version of the macro cannot be more specific, but it is assumed that T: MLNRawRepresentable.
// This bound should be reintroduced when the packages are re-merged.
@attached(member, names: arbitrary)
public macro MLNRawRepresentableStyleProperty<T>(_ named: String) = #externalMacro(
    module: "MapLibreSwiftMacrosImpl",
    type: "MLNRawRepresentableStylePropertyMacro"
)
