import SwiftUI
import MapKit

@main
struct MapApp: App {
    var body: some Scene {
        WindowGroup {
            MapView()
        }
    }
}

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var fromLocation: String = ""
    @State private var toLocation: String = ""
    @State private var destination: CLLocationCoordinate2D?
    @State private var showingRoute = false

    var body: some View {
        VStack {
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                userTrackingMode: .constant(trackingMode),
                annotationItems: viewModel.annotations) { annotation in
                    MapAnnotation(coordinate: annotation.annotation.coordinate) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                destination = annotation.annotation.coordinate
                            }
                    }
                }
                .onAppear {
                    viewModel.checkIfLocationServicesIsEnabled()
                }
                .accentColor(Color(.systemPink))
                .onTapGesture {
                    destination = nil
                }

            HStack {
                TextField("From", text: $fromLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("To", text: $toLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    showingRoute = true
                }, label: {
                    Text("Show Route")
                })
                .padding()
                .disabled(fromLocation.isEmpty || toLocation.isEmpty)
            }

            if showingRoute {
                Button(action: {
                    showingRoute = false
                }, label: {
                    Text("Hide Route")
                })
                .padding()

                // Call a function here to show the route using MapKit Directions API
            }
        }
    }
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

    private var locationManager = CLLocationManager()

    var annotations: [IdentifiableAnnotation] {
        var annotations = [IdentifiableAnnotation]()
        if let userLocation = userLocation {
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = userLocation
            userAnnotation.title = "User Location"
            annotations.append(IdentifiableAnnotation(annotation: userAnnotation))
        }
        return annotations
    }

    var userLocation: CLLocationCoordinate2D? {
        didSet {
            objectWillChange.send()
        }
    }

    override init() {
        super.init()
        self.locationManager.delegate = self
    }

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            // Handle the case where location services are not enabled
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        self.region = MKCoordinateRegion(center: latestLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.userLocation = latestLocation.coordinate
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            // Handle the case where permission is denied
            break
        default:
            break
        }
    }
}

// Wrapper struct for MKPointAnnotation to conform to Identifiable
struct IdentifiableAnnotation: Identifiable {
    var id = UUID()
    var annotation: MKPointAnnotation
}

