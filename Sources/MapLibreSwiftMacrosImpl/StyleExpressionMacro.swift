import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

enum StyleExpressionMacroError: CustomStringConvertible, Error {
    case invalidArguments
    case missingGenericType

    var description: String {
        switch self {
        case .invalidArguments: return "@StyleExpression must have arguments of the form @StyleExpression<T>(named: \"identifier\")"
        case .missingGenericType: return "@StyleExpression must have a generic type constraint"
        }
    }
}

private let allowedKeys = Set(["supportsInterpolation"])

private func generateStyleExpression(for attributes: AttributeSyntax, isRawRepresentable: Bool) throws -> [DeclSyntax] {
    guard let args = attributes.arguments, let exprs = args.as(LabeledExprListSyntax.self), exprs.count >= 1, let identifierString = exprs.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue else {
        throw StyleExpressionMacroError.invalidArguments
    }

    let flags = Dictionary(uniqueKeysWithValues: try exprs.dropFirst().map { expr in
        guard let key = expr.label?.text, allowedKeys.contains(key), let tokenKind = expr.expression.as(BooleanLiteralExprSyntax.self)?.literal.tokenKind else {
            throw StyleExpressionMacroError.invalidArguments
        }
        return (key, tokenKind == TokenKind.keyword(.true))
    })

    guard let genericArgument = attributes
        .attributeName.as(IdentifierTypeSyntax.self)?
        .genericArgumentClause?
        .arguments.first?
        .argument else {
        throw StyleExpressionMacroError.missingGenericType
    }

    let identifier = TokenSyntax(stringLiteral: identifierString)

    let varDeclSyntax = DeclSyntax("fileprivate var \(identifier): NSExpression? = nil")

    let constantFuncDecl = try generateFunctionDeclSyntax(identifier: identifier, genericArgument: genericArgument, isRawRepresentable: isRawRepresentable)

    let getPropFuncDecl = try FunctionDeclSyntax("public func \(identifier)(featurePropertyNamed keyPath: String) -> Self") {
        "var copy = self"
        "copy.\(identifier) = NSExpression(forKeyPath: keyPath)"
        "return copy"
    }

    guard let constFuncDeclSyntax = DeclSyntax(constantFuncDecl),
          let getPropFuncDeclSyntax = DeclSyntax(getPropFuncDecl) else {
        throw StyleExpressionMacroError.invalidArguments
    }

    var extra: [DeclSyntax] = []

    if flags["supportsInterpolation"] == .some(true) {
        let interpolationFuncDecl = try FunctionDeclSyntax("public func \(identifier)(interpolatedBy expression: MLNVariableExpression, curveType: MLNExpressionInterpolationMode, parameters: NSExpression?, stops: NSExpression) -> Self") {
            "var copy = self"
            "copy.\(identifier) = interpolatingExpression(expression: expression, curveType: curveType, parameters: parameters, stops: stops)"
            "return copy"
        }

        guard let interpolationFuncDeclSyntax = DeclSyntax(interpolationFuncDecl) else {
            throw StyleExpressionMacroError.invalidArguments
        }

        extra.append(interpolationFuncDeclSyntax)
    }

    return [varDeclSyntax, constFuncDeclSyntax, getPropFuncDeclSyntax] + extra
}

private func generateFunctionDeclSyntax(identifier: TokenSyntax, genericArgument: TypeSyntax, isRawRepresentable: Bool) throws -> FunctionDeclSyntax {
    if (isRawRepresentable) {
        return try FunctionDeclSyntax("public func \(identifier)(constant value: \(genericArgument)) -> Self") {
            "var copy = self"
            "copy.\(identifier) = NSExpression(forConstantValue: value.mlnRawValue.rawValue)"
            "return copy"
        }
    } else {
        return try FunctionDeclSyntax("public func \(identifier)(constant value: \(genericArgument)) -> Self") {
            "var copy = self"
            "copy.\(identifier) = NSExpression(forConstantValue: value)"
            "return copy"
        }
    }
}

public struct StyleExpressionMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [DeclSyntax] {
        return try generateStyleExpression(for: node, isRawRepresentable: false)
    }
}

public struct StyleRawRepresentableExpressionMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [DeclSyntax] {
        return try generateStyleExpression(for: node, isRawRepresentable: true)
    }
}
