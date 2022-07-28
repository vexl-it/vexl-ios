//
//  MapView.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/13/21.
//

import SwiftUI
import MapKit

public struct MapView: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    public func updateUIView(_ uiView: MKMapView, context: Context) {}

    public func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(self)
    }

    public class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}
