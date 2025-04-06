import SwiftUI
import CoreLocation

// MARK: - LocationManager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        // Request "When In Use" authorization
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied/restricted.")
        case .notDetermined:
            print("Location permission not determined yet.")
        @unknown default:
            print("Unknown authorization status.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        // If you only want one location reading, you could stop here:
        // manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}

// MARK: - LocTestView
struct LocTestView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Location Test")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 60)
            
            // Display user coordinates if we have them
            if let lat = locationManager.latitude,
               let lng = locationManager.longitude {
                Text("Latitude: \(lat)")
                    .font(.title2)
                Text("Longitude: \(lng)")
                    .font(.title2)
            } else {
                Text("Coordinates not available yet.")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            // Button to request location
            Button(action: {
                locationManager.requestLocation()
            }) {
                Text("Get Location")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct LocTestView_Previews: PreviewProvider {
    static var previews: some View {
        LocTestView()
    }
}
