//
//  GoogleMapView.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    @ObservedObject var vm: MapViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition(latitude: 20.0, longitude: 78.0, zoom: 3)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = false
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()

        guard !vm.images.isEmpty else { return }

        var bounds = GMSCoordinateBounds()

        for img in vm.images {
            let coord = CLLocationCoordinate2D(latitude: img.coordinate.lat,
                                               longitude: img.coordinate.lon)

            let marker = GMSMarker(position: coord)
            marker.title = img.author
            marker.snippet = "ID: \(img.id)"
            marker.map = mapView

            bounds = bounds.includingCoordinate(coord)
        }

        // Fit markers in the screen
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80)
        mapView.moveCamera(update)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView

        init(_ parent: GoogleMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            // Find image whose coordinates match this marker
            let coord = marker.position
            if let img = parent.vm.images.first(where: {
                abs($0.coordinate.lat - coord.latitude) < 0.0005 &&
                abs($0.coordinate.lon - coord.longitude) < 0.0005
            }) {
                parent.vm.select(image: img)
            }
            return false // allow default behavior (show marker info window)
        }
    }
}


//public struct GoogleMapView: UIViewRepresentable {
//    public typealias UIViewType = GMSMapView
//    @ObservedObject public var vm: MapViewModel
//
//    public init(viewModel: MapViewModel) {
//        self.vm = viewModel
//    }
//
//    public func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    public func makeUIView(context: Context) -> GMSMapView {
//        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1.5)
//        let map = GMSMapView(frame: .zero, camera: camera)
//        map.delegate = context.coordinator
//        map.mapType = .normal
//        return map
//    }
//
//    public func updateUIView(_ uiView: GMSMapView, context: Context) {
//        uiView.clear()
//        guard !vm.images.isEmpty else { return }
//        var bounds = GMSCoordinateBounds()
//        for img in vm.images {
//            let coord = img.coordinate
//            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon))
//            marker.userData = img
//            if let urlString = img.download_url, let url = URL(string: urlString) {
//                // Use thumbnail via picsum thumbnail endpoint
//                let thumbURL = URL(string: "https://picsum.photos/80/80?image=\(img.id)") // or use id-based
//                // we avoid asynchronous thumbnail setting here to keep code simple; marker.icon can be an UIImage loaded async in a Coordinator if desired
//                // set default icon
//                marker.icon = GMSMarker.markerImage(with: .systemBlue)
//            }
//            marker.map = uiView
//            bounds = bounds.includingCoordinate(marker.position)
//        }
//        // camera fit
//        uiView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 40.0))
//    }
//
//    public class Coordinator: NSObject, GMSMapViewDelegate {
//        let parent: GoogleMapView
//        init(_ parent: GoogleMapView) { self.parent = parent }
//
//        @MainActor public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//            if let img = marker.userData as? PicsumImage {
//                parent.vm.select(image: img)
//            }
//            return true
//        }
//    }
//}
