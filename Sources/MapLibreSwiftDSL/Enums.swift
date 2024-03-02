import InternalUtils
import MapLibre

// This file exists for convenience until / unless
// this is merged into the MapLibre Native Swift module OR Swift gains the
// ability to re-export types from dependencies.

public enum LineCap {
    case butt
    case round
    case square
}

extension LineCap: MLNRawRepresentable {
    public var mlnRawValue: MLNLineCap {
        switch self {
        case .butt: .butt
        case .round: .round
        case .square: .square
        }
    }
}

public enum LineJoin {
    case bevel
    case miter
    case round
}

extension LineJoin: MLNRawRepresentable {
    public var mlnRawValue: MLNLineJoin {
        switch self {
        case .bevel: .bevel
        case .miter: .miter
        case .round: .round
        }
    }
}

public enum MLNVariableExpression {
    case featureAccumulated
    case featureAttributes
    case featureIdentifier
    case geometryType
    case heatmapDensity
    case lineProgress
    case zoomLevel
}

extension MLNVariableExpression {
    var nsExpression: NSExpression {
        switch self {
        case .featureAccumulated:
            .featureAccumulatedVariable
        case .featureAttributes:
            .featureAttributesVariable
        case .featureIdentifier:
            .featureIdentifierVariable
        case .geometryType:
            .geometryTypeVariable
        case .heatmapDensity:
            .heatmapDensityVariable
        case .lineProgress:
            .lineProgressVariable
        case .zoomLevel:
            .zoomLevelVariable
        }
    }
}
