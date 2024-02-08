import Foundation

/// Enforces a basic set of result builder definiitons.
///
/// This is just a tool to make a result builder easier to build, maintain sorting, etc.
protocol DefaultResultBuilder {
        
    associatedtype Component
    
    static func buildExpression(_ expression: Component) -> [Component]
    
    static func buildExpression(_ expression: [Component]) -> [Component]
    
    // MARK: Handle void
    
    static func buildExpression(_ expression: Void) -> [Component]
    
    // MARK: Combine elements into an array
    
    static func buildBlock(_ components: [Component]...) -> [Component]
    
    // MARK: Handle Arrays
    
    static func buildArray(_ components: [Component]) -> [Component]
    
    // MARK: Handle for in loops
    
    static func buildArray(_ components: [[Component]]) -> [Component]
    
    // MARK: Handle if statements
    
    static func buildEither(first components: [Component]) -> [Component]
    
    static func buildEither(second components: [Component]) -> [Component]
    
    // MARK: Handle Optionals
    
    static func buildOptional(_ components: [Component]?) -> [Component]
}
