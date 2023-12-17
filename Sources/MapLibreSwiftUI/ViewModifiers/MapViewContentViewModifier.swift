//
//  File.swift
//  
//
//  Created by Jacob Fielding on 12/16/23.
//

import SwiftUI
import MapLibreSwiftDSL

extension MapView {
    
    public func mapContent(@MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition]) -> MapView {
        switch self.styleSource {
            
        case .url(let styleUrl):
            return MapView(styleURL: styleUrl,
                           camera: self.camera,
                           makeMapContent)
        }
    }
}
