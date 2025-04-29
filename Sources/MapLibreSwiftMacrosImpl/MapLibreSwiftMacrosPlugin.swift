import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MapLibreSwiftMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MLNStylePropertyMacro.self,
        MLNRawRepresentableStylePropertyMacro.self,
    ]
}
