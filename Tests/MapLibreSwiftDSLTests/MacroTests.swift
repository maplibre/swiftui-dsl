//
//  File.swift
//  
//
//  Created by Ian Wagner on 2023-09-22.
//

import Foundation
import MapLibreSwiftMacrosImpl
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "ConstStyleExpression" : ConstStyleExpressionMacro.self,
]

final class ExpressionTests: XCTestCase {
    // NOTE: This test will fail as it is a WIP commit. Also look at https://github.com/pointfreeco/swift-macro-testing
    // for testing once we get cooking for real.
    func testConstStyleExpression() {
        assertMacroExpansion(
            """
            @ConstStyleExpression(backgroundColor: UIColor.black)
            struct Layer {
            }
            """,
            expandedSource: """
             struct Layer {
                 var backgroundColor: UIColor = .black
             }
             """,
            macros: testMacros)
    }
}
