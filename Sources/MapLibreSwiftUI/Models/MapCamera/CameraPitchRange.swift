import Foundation
import MapLibre

/// The current pitch state for the MapViewCamera
public enum CameraPitchRange: Hashable, Sendable {
    /// The user is free to control pitch from it's default min to max.
    case free

    /// The user is free to control pitch within the minimum and maximum range.
    case freeWithinRange(minimum: Double, maximum: Double)

    /// The pitch is fixed to a certain value.
    case fixed(Double)

    /// The range of acceptable pitch values.
    ///
    /// This is applied to the map view on camera updates.
	public var rangeValue: ClosedRange<Double> {
        switch self {
        case .free:
            0 ... 60 // TODO: set this to a maplibre constant (this is available on Android, but maybe not iOS)?
        case let .freeWithinRange(minimum: minimum, maximum: maximum):
            minimum ... maximum
        case let .fixed(value):
            value ... value
        }
    }
}
