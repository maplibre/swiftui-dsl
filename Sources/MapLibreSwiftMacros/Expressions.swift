import Foundation

@attached(member, names: arbitrary)
public macro ConstStyleExpression<T>(named: String, defaultValue: T) = #externalMacro(module: "MapLibreSwiftMacrosImpl", type: "ConstStyleExpressionMacro")
