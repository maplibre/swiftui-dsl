import SwiftCompilerPlugin
import SwiftSyntaxMacros


@main
struct MapLibreSwiftMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ConstStyleExpressionMacro.self
    ]
}
