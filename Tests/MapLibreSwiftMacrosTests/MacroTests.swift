import Foundation
import MapLibreSwiftMacrosImpl
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest


final class ExpressionTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(macros: [
            MLNStylePropertyMacro.self,
            MLNRawRepresentableStylePropertyMacro.self,
        ]) {
            super.invokeTest()
        }
    }

    // TODO: Non-enum attachment

    func testFail() {
        XCTAssert(false)
    }

    func testMLNStylePropertyValid() {
        assertMacro {
            """
            @MLNStyleProperty<UIColor>("backgroundColor")
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
            @MLNStyleProperty<UIColor>("backgroundColor", supportsInterpolation: false)
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

    func testMLNStylePropertyValidWithSupportedExpressions() {
        assertMacro {
            """
            @MLNStyleProperty<UIColor>("backgroundColor", supportsInterpolation: true)
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
            @MLNRawRepresentableStyleProperty<UIColor>("backgroundColor")
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
