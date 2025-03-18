import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private let allowedKeys = Set(["supportsInterpolation"])

private func generateStyleProperty(for attributes: AttributeSyntax, valueType: TypeSyntax,
                                   isRawRepresentable: Bool) throws -> [DeclSyntax]
{
    guard let args = attributes.arguments, let exprs = args.as(LabeledExprListSyntax.self), exprs.count >= 1,
          let identifierString = exprs.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
    else {
        fatalError("Compiler bug: this macro did not receive arguments per its public signature.")
    }

    let flags = Dictionary(uniqueKeysWithValues: exprs.dropFirst().map { expr in
        guard let key = expr.label?.text, allowedKeys.contains(key),
              let tokenKind = expr.expression.as(BooleanLiteralExprSyntax.self)?.literal.tokenKind
        else {
            fatalError("Compiler bug: this macro did not receive arguments per its public signature.")
        }
        return (key, tokenKind == TokenKind.keyword(.true))
    })

    let identifier = TokenSyntax(stringLiteral: identifierString)

    let varDeclSyntax = DeclSyntax("fileprivate var \(identifier): NSExpression? = nil")

    let constantFuncDecl = try generateFunctionDeclSyntax(
        identifier: identifier,
        valueType: valueType,
        isRawRepresentable: isRawRepresentable
    )

    let nsExpressionFuncDecl = try FunctionDeclSyntax("public func \(identifier)(expression: NSExpression) -> Self") {
        "var copy = self"
        "copy.\(identifier) = expression"
        "return copy"
    }

    let getPropFuncDecl =
        try FunctionDeclSyntax("public func \(identifier)(featurePropertyNamed keyPath: String) -> Self") {
            "var copy = self"
            "copy.\(identifier) = NSExpression(forKeyPath: keyPath)"
            "return copy"
        }

    guard let constFuncDeclSyntax = DeclSyntax(constantFuncDecl),
          let getPropFuncDeclSyntax = DeclSyntax(getPropFuncDecl),
          let nsExpressionFuncDeclSyntax = DeclSyntax(nsExpressionFuncDecl)
    else {
        fatalError("SwiftSyntax bug or implementation error: unable to construct DeclSyntax")
    }

    var extra: [DeclSyntax] = []

    if flags["supportsInterpolation"] == .some(true) {
        let interpolationFuncDecl =
            try FunctionDeclSyntax(
                "public func \(identifier)(interpolatedBy expression: MLNVariableExpression, curveType: MLNExpressionInterpolationMode, parameters: NSExpression?, stops: NSExpression) -> Self"
            ) {
                "var copy = self"
                "copy.\(identifier) = interpolatingExpression(expression: expression, curveType: curveType, parameters: parameters, stops: stops)"
                "return copy"
            }

        guard let interpolationFuncDeclSyntax = DeclSyntax(interpolationFuncDecl) else {
            fatalError("SwiftSyntax bug or implementation error: unable to construct DeclSyntax")
        }

        extra.append(interpolationFuncDeclSyntax)
    }

    return [varDeclSyntax, constFuncDeclSyntax, nsExpressionFuncDeclSyntax, getPropFuncDeclSyntax] + extra
}

private func generateFunctionDeclSyntax(identifier: TokenSyntax, valueType: TypeSyntax,
                                        isRawRepresentable: Bool) throws -> FunctionDeclSyntax
{
    if isRawRepresentable {
        try FunctionDeclSyntax("public func \(identifier)(_ value: \(valueType)) -> Self") {
            "var copy = self"
            "copy.\(identifier) = NSExpression(forConstantValue: value.mlnRawValue.rawValue)"
            "return copy"
        }
    } else {
        try FunctionDeclSyntax("public func \(identifier)(_ value: \(valueType)) -> Self") {
            "var copy = self"
            "copy.\(identifier) = NSExpression(forConstantValue: value)"
            "return copy"
        }
    }
}

public struct MLNStylePropertyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf _: some DeclGroupSyntax,
        in _: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let genericArgument = node
            .attributeName.as(IdentifierTypeSyntax.self)?
            .genericArgumentClause?
            .arguments.first?
            .argument
        else {
            fatalError("Compiler bug: this macro is missing a generic type constraint.")
        }

        return try generateStyleProperty(for: node, valueType: genericArgument, isRawRepresentable: false)
    }
}

public struct MLNRawRepresentableStylePropertyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf _: some DeclGroupSyntax,
        in _: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let genericArgument = node
            .attributeName.as(IdentifierTypeSyntax.self)?
            .genericArgumentClause?
            .arguments.first?
            .argument
        else {
            fatalError("Compiler bug: this macro is missing a generic type constraint.")
        }

        return try generateStyleProperty(for: node, valueType: genericArgument, isRawRepresentable: true)
    }
}
