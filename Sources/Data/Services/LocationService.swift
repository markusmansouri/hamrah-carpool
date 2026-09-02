import Foundation
import MapKit

public protocol LocationService {
    func getCurrentLocation() async -> Result<GeoPoint, LocationError>
    func getAddress(for location: GeoPoint) async -> Result<String, LocationError>
    func getCoordinates(for address: String) async -> Result<GeoPoint, LocationError>
    func calculateDistance(from: GeoPoint, to: GeoPoint) -> Double
    func calculateRoute(from: GeoPoint, to: GeoPoint) async -> Result<[GeoPoint], LocationError>
}

public final class AppleLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    public static let shared = AppleLocationService()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func getCurrentLocation() async -> Result<GeoPoint, LocationError> {
        locationManager.requestWhenInUseAuthorization()
        
        return await withCheckedContinuation { continuation in
            let handler: @MainActor () -> Void = { [weak self] in
                guard let currentLocation = self?.locationManager.location else {
                    continuation.resume(returning: .failure(.locationNotFound))
                    return
                }
                
                let geoPoint = GeoPoint(
                    latitude: currentLocation.coordinate.latitude,
                    longitude: currentLocation.coordinate.longitude
                )
                continuation.resume(returning: .success(geoPoint))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: handler)
        }
    }
    
    public func getAddress(for location: GeoPoint) async -> Result<String, LocationError> {
        let clLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)
            guard let placemark = placemarks.first else {
                return .failure(.locationNotFound)
            }
            
            let address = [
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.postalCode
            ].compactMap { $0 }.joined(separator: ", ")
            
            return .success(address)
        } catch {
            return .failure(.networkError)
        }
    }
    
    public func getCoordinates(for address: String) async -> Result<GeoPoint, LocationError> {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            guard let placemark = placemarks.first,
                  let location = placemark.location else {
                return .failure(.locationNotFound)
            }
            
            let geoPoint = GeoPoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            return .success(geoPoint)
        } catch {
            return .failure(.networkError)
        }
    }
    
    public func calculateDistance(from: GeoPoint, to: GeoPoint) -> Double {
        let fromLocation = CLLocation(
            latitude: from.latitude,
            longitude: from.longitude
        )
        let toLocation = CLLocation(
            latitude: to.latitude,
            longitude: to.longitude
        )
        
        return fromLocation.distance(from: toLocation) / 1000.0 // Convert to km
    }
    
    public func calculateRoute(from: GeoPoint, to: GeoPoint) async -> Result<[GeoPoint], LocationError> {
        let request = MKDirections.Request()
        request.source = MKMapItem(
            placemark: MKPlacemark(
                coordinate: CLLocationCoordinate2D(
                    latitude: from.latitude,
                    longitude: from.longitude
                )
            )
        )
        request.destination = MKMapItem(
            placemark: MKPlacemark(
                coordinate: CLLocationCoordinate2D(
                    latitude: to.latitude,
                    longitude: to.longitude
                )
            )
        )
        
        do {
            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            
            guard let route = response.routes.first else {
                return .failure(.networkError)
            }
            
            let coordinates = route.polyline.points()
                .map { point -> GeoPoint in
                    GeoPoint(
                        latitude: point.coordinate.latitude,
                        longitude: point.coordinate.longitude
                    )
                }
            
            return .success(coordinates)
        } catch {
            return .failure(.networkError)
        }
    }
}
