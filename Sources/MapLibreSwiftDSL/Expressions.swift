// Helpers to construct MapLibre GL expressions
import Foundation
import MapLibre


// TODO: Generalize this into a macro? Revisit once Swift 5.9 lands
public func interpolatingExpression(expression: MLNVariableExpression, curveType: MLNExpressionInterpolationMode, parameters: NSExpression?, stops: NSExpression) -> NSExpression {
    return NSExpression(forMLNInterpolating: expression.nsExpression,
                        curveType: curveType,
                        parameters: parameters,
                        stops: stops)
}
