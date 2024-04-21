import SwiftUI
import MapKit

struct NavigationMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683), // Default coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    var destination: String
    private let locationManager = CLLocationManager()

    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear {
                setupLocationManager()
                geocodeDestination()
            }
    }

    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        updateRegionToCurrentLocation()
    }

    private func updateRegionToCurrentLocation() {
        if let currentLocation = locationManager.location?.coordinate {
            region = MKCoordinateRegion(
                center: currentLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }

    func geocodeDestination() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(destination) { (placemarks, error) in
            if let places = placemarks, let place = places.first, let location = place.location {
                region.center = location.coordinate
            }
        }
    }
}

