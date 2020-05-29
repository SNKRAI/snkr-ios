import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    private let locations: [CLLocation]

    init(with locations: [CLLocation]) {
        self.locations = locations
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        guard !locations.isEmpty else { return }
        let coordinates = locations.map { $0.coordinate }
        let geodesic = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
        view.addOverlay(geodesic)
        
        if let center = locations.first?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: center, span: span)
            view.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        return coordinator
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
        
         func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay.isKind(of: MKGeodesicPolyline.self) {
                let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor = .red
                polylineRenderer.lineWidth = 3
                return polylineRenderer
            }
    
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

