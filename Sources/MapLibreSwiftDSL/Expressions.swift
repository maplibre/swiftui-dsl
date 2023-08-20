// Helpers to construct MapLibre GL expressions
import Foundation
import Mapbox


// TODO: Generalize this into a macro once Swift 5.9 lands
public func interpolatingExpression(expression: MGLVariableExpression, curveType: MGLExpressionInterpolationMode, parameters: NSExpression?, stops: NSExpression) -> NSExpression {
    return NSExpression(forMGLInterpolating: expression.nsExpression,
                        curveType: curveType,
                        parameters: parameters,
                        stops: stops)
}
