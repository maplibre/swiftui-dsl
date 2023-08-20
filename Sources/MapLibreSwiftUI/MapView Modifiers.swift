// This file contains modifiers that are internal and specific to the MapView.
// They are not intended to be exposed directly in the public interface.

import Foundation
import InternalUtils
import CoreLocation
import SwiftUI

extension MapView {
    public func initialCenter(center: CLLocationCoordinate2D, zoom: Double? = nil) -> Self {
        return modified(self, using: { $0.initialCamera = .centerAndZoom(center, zoom) })
    }
}
