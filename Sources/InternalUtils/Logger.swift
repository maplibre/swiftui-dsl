import os

public extension Logger {
    init(category: String) {
        self.init(subsystem: "MapLibre-SwiftUI", category: category)
    }
}
