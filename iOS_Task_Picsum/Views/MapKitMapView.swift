//
//  MapKitMapView.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//


import SwiftUI
import MapKit

struct MapKitMapView: UIViewRepresentable {
    @ObservedObject var vm: MapViewModel

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.mapType = .standard
        map.showsUserLocation = false
        map.isRotateEnabled = false
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove existing annotations and add new ones (simple and robust)
        uiView.removeAnnotations(uiView.annotations)

        guard !vm.images.isEmpty else { return }

        var rect: MKMapRect?
        for img in vm.images {
            let coord = CLLocationCoordinate2D(latitude: img.coordinate.lat, longitude: img.coordinate.lon)
            let ann = MKPointAnnotation()
            ann.coordinate = coord
            ann.title = img.author
            ann.subtitle = img.id
            uiView.addAnnotation(ann)

            let pt = MKMapPoint(coord)
            let r = MKMapRect(x: pt.x, y: pt.y, width: 0, height: 0)
            rect = rect?.union(r) ?? r
        }

        // adjust visible rect to fit all annotations (with safe padding)
        if let r = rect {
            uiView.setVisibleMapRect(r, edgePadding: UIEdgeInsets(top: 60, left: 40, bottom: 220, right: 40), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitMapView

        init(_ parent: MapKitMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation else { return }
            // find image by approximate coordinate match
            if let img = parent.vm.images.first(where: {
                abs($0.coordinate.lat - ann.coordinate.latitude) < 0.0005 &&
                abs($0.coordinate.lon - ann.coordinate.longitude) < 0.0005
            }) {
                // This will trigger the sheet
                parent.vm.select(image: img)
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            let id = "picsumAnnotation"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            if view == nil {
                let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
                marker.canShowCallout = true
                // optionally add a small image on callout right accessory using thumbnail URL if you want
                marker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                view = marker
            } else {
                view?.annotation = annotation
            }
            return view
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let ann = view.annotation else { return }
            if let img = parent.vm.images.first(where: {
                abs($0.coordinate.lat - ann.coordinate.latitude) < 0.0005 &&
                abs($0.coordinate.lon - ann.coordinate.longitude) < 0.0005
            }) {
                parent.vm.select(image: img)
            }
        }
    }
}
