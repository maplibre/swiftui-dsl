import Foundation
import InternalUtils

/// Adds a stored property and modifiers for an attribute that can be styled using a MapLibre style expression.
///
/// Layout and paint properties may be specified using expresisons.
/// Some expressions may suppeort more types of expressions than others (ex: interpolated).
/// TODO: Figure out where these edges are.
@attached(member, names: arbitrary)
public macro StyleExpression<T>(_ named: String, supportsInterpolation: Bool = false) = #externalMacro(module: "MapLibreSwiftMacrosImpl", type: "StyleExpressionMacro")

@attached(member, names: arbitrary)
public macro StyleRawRepresentableExpression<T: MLNRawRepresentable>(_ named: String) = #externalMacro(module: "MapLibreSwiftMacrosImpl", type: "StyleRawRepresentableExpressionMacro")
