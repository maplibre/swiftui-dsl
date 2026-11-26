import SwiftUI

/// "Renders" an SFSymbols glyph by name.
///
/// This is a bit of a hack for the moment, but so far we haven't been able
/// to render certain things without it.
@MainActor
func previewSymbol(named name: String) -> UIImage {
    guard let symbol = UIImage(systemName: name) else {
        preconditionFailure("The preview symbol is not available.")
    }
    // MapLibre style images need bitmap data.
    return UIGraphicsImageRenderer(size: symbol.size).image { _ in
        symbol.draw(at: .zero)
    }
}
