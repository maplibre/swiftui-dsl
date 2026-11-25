import SwiftUI

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
