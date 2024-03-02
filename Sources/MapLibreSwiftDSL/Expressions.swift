// Helpers to construct MapLibre GL expressions
import Foundation
import MapLibre

// TODO: Parameters and stops need nicer interfaces
// TODO: Expression should be able to accept other expressions like variable getters. Probably should be a protocol?
public func interpolatingExpression(
    expression: MLNVariableExpression,
    curveType: MLNExpressionInterpolationMode,
    parameters: NSExpression?,
    stops: NSExpression
) -> NSExpression {
    NSExpression(forMLNInterpolating: expression.nsExpression,
                 curveType: curveType,
                 parameters: parameters,
                 stops: stops)
}
