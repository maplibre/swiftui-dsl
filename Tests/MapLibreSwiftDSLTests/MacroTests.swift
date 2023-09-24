import Foundation
import MapLibreSwiftMacrosImpl
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest


final class ExpressionTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(macros: [
            "StyleExpression" : StyleExpressionMacro.self,
            "StyleRawRepresentableExpression" : StyleRawRepresentableExpressionMacro.self,
        ]) {
            super.invokeTest()
        }
    }

    // TODO: Invalid test cases
    // @StyleExpression()
    // Non-enum attachment

    func testStyleExpressionMissingArgument() {
        assertMacro {
            """
            @StyleExpression<UIColor>()
            struct Layer {
            }
            """
        } matches: {
            """
            @StyleExpression<UIColor>()
            ┬──────────────────────────
            ╰─ 🛑 @StyleExpression must have arguments of the form @StyleExpression<T>(named: "identifier")
            struct Layer {
            }
            """
        }
    }

    func testStyleExpressionExtraArgument() {
        assertMacro {
            """
            @StyleExpression<UIColor>(named: "backgroundColor", foo: bar)
            struct Layer {
            }
            """
        } matches: {
            """
            @StyleExpression<UIColor>(named: "backgroundColor", foo: bar)
            ┬────────────────────────────────────────────────────────────
            ╰─ 🛑 @StyleExpression must have arguments of the form @StyleExpression<T>(named: "identifier")
            struct Layer {
            }
            """
        }
    }

    func testStyleExpressionMissingGeneric() {
        assertMacro {
            """
            @StyleExpression(named: "backgroundColor")
            struct Layer {
            }
            """
        } matches: {
            """
            @StyleExpression(named: "backgroundColor")
            ┬─────────────────────────────────────────
            ╰─ 🛑 @StyleExpression must have a generic type constraint
            struct Layer {
            }
            """
        }
    }

    func testStyleExpressionValid() {
        assertMacro {
            """
            @StyleExpression<UIColor>(named: "backgroundColor")
            struct Layer {
            }
            """
        } matches: {
            """
            struct Layer {

                fileprivate var backgroundColor: NSExpression? = nil

                public func backgroundColor(constant value: UIColor) -> Self {
                    var copy = self
                    copy.backgroundColor = NSExpression(forConstantValue: value)
                    return copy
                }

                public func backgroundColor(featurePropertyNamed keyPath: String) -> Self {
                    var copy = self
                    copy.backgroundColor = NSExpression(forKeyPath: keyPath)
                    return copy
                }
            }
            """
        }

        assertMacro {
            """
            @StyleExpression<UIColor>(named: "backgroundColor", supportsInterpolation: false)
            struct Layer {
            }
            """
        } matches: {
            """
            struct Layer {

                fileprivate var backgroundColor: NSExpression? = nil

                public func backgroundColor(constant value: UIColor) -> Self {
                    var copy = self
                    copy.backgroundColor = NSExpression(forConstantValue: value)
                    return copy
                }

                public func backgroundColor(featurePropertyNamed keyPath: String) -> Self {
                    var copy = self
                    copy.backgroundColor = NSExpression(forKeyPath: keyPath)
                    return copy
                }
            }
            """
        }
    }

    func testStyleExpressionValidWithSupportedExpressions() {
        assertMacro {
            """
            @StyleExpression<UIColor>(named: "backgroundColor", supportsInterpolation: true)
            struct Layer {
            }
            """
        } matches: {
            """
            struct Layer {

                fileprivate var backgroundColor: NSExpression? = nil

                public func backgroundColor(constant value: UIColor) -> Self {
                    var copy = self
                    copy.backgroundColor = NSExpression(forConstantValue: value)
                    return copy
                }

                public func backgroundColor(featurePropertyNamed keyPath: String) -> Self {
                    var copy = self
                    copy.backgroundColor = NSExpression(forKeyPath: keyPath)
                    return copy
                }

                public func backgroundColor(interpolatedBy expression: MLNVariableExpression, curveType: MLNExpressionInterpolationMode, parameters: NSExpression?, stops: NSExpression) -> Self {
                    var copy = self
                    copy.backgroundColor = interpolatingExpression(expression: expression, curveType: curveType, parameters: parameters, stops: stops)
                    return copy
                }
            }
            """
        }
    }

    func testStyleRawExpressionValid() {
        assertMacro {
            """
            @StyleRawRepresentableExpression<UIColor>(named: "backgroundColor")
            struct Layer {
            }
            """
        } matches: {
            """
            struct Layer {

                fileprivate var backgroundColor: NSExpression? = nil

                public func backgroundColor(constant value: UIColor) -> Self {
                    var copy = self
                    copy.backgroundColor = NSExpression(forConstantValue: value.mlnRawValue.rawValue)
                    return copy
                }

                public func backgroundColor(featurePropertyNamed keyPath: String) -> Self {
                    var copy = self
                    copy.backgroundColor = NSExpression(forKeyPath: keyPath)
                    return copy
                }
            }
            """
        }
    }
}
