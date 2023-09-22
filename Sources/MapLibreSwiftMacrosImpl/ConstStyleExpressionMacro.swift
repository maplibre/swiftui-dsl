import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

// TODO: Impl goes here
public struct ConstStyleExpressionMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [DeclSyntax] {
        // TODO: Something like this
//        VariableDeclSyntax(bindingSpecifier: "var", bindings: <#T##PatternBindingListSyntax#>)
        return []
    }
}
