import MapLibre

/// A tile lifecycle operation from a map view.
public struct MapTileEvent: Equatable, Sendable {
    /// The operation that MapLibre reported for the tile.
    public let operation: MLNTileOperation

    /// The identifier of the tile source.
    public let sourceID: String
}
