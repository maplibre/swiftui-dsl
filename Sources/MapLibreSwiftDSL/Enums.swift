import Mapbox

// This file exists almost for convenience until / unless
// this is merged into the MapLibre Native Swift module OR Swift gains the
// ability to re-export types from dependencies.

public enum LineCap {
    case butt
    case round
    case square
}

extension LineCap {
    var mglLineCapValue: MGLLineCap {
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
    var mglLineJoinValue: MGLLineJoin {
        switch self {
        case .bevel: return .bevel
        case .miter: return .miter
        case .round: return .round
        }
    }
}
