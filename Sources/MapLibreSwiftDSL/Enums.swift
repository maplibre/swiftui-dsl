import MapLibre

// This file exists for convenience until / unless
// this is merged into the MapLibre Native Swift module OR Swift gains the
// ability to re-export types from dependencies.

public enum LineCap {
    case butt
    case round
    case square
}

extension LineCap {
    var mglLineCapValue: MLNLineCap {
        switch self {
        case .butt: return .butt
        case .round: return .round
        case .square: return .square
        }
    }
}

public enum LineJoin {
    case bevel
    case miter
    case round
}

extension LineJoin {
    var mglLineJoinValue: MLNLineJoin {
        switch self {
        case .bevel: return .bevel
        case .miter: return .miter
        case .round: return .round
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
            return .featureAccumulatedVariable
        case .featureAttributes:
            return .featureAttributesVariable
        case .featureIdentifier:
            return .featureIdentifierVariable
        case .geometryType:
            return .geometryTypeVariable
        case .heatmapDensity:
            return .heatmapDensityVariable
        case .lineProgress:
            return .lineProgressVariable
        case .zoomLevel:
            return .zoomLevelVariable
        }
    }
}
