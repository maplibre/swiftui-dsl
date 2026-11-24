import MapLibre
import MapLibreSwiftDSL

extension StyleLayerDefinition {
    /// The source that the DSL manages for this layer.
    ///
    /// This is `nil` if the layer has no source, or if its source is an ``MLNSource`` that the app manages.
    var managedSource: Source? {
        guard let layer = self as? SourceBoundStyleLayerDefinition, case let .source(source) = layer.source else {
            return nil
        }
        return source
    }

    /// Makes the MapLibre layer, with the visibility and zoom levels of this definition.
    ///
    /// This adds the source of the layer to `style` if it is not there.
    func makeMLNStyleLayer(in style: MLNStyle) -> MLNStyleLayer {
        let styleLayer = makeStyleLayer(style: style).makeMLNStyleLayer()
        styleLayer.isVisible = isVisible
        if let minimumZoomLevel {
            styleLayer.minimumZoomLevel = minimumZoomLevel
        }
        if let maximumZoomLevel {
            styleLayer.maximumZoomLevel = maximumZoomLevel
        }
        return styleLayer
    }
}
