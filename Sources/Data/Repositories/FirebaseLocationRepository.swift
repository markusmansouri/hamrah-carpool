import Foundation

public final class FirebaseLocationRepository: LocationRepository {
    private let realtimeDatabaseDataSource: RealtimeDatabaseDataSource
    
    public init(realtimeDatabaseDataSource: RealtimeDatabaseDataSource) {
        self.realtimeDatabaseDataSource = realtimeDatabaseDataSource
    }
    
    public func startTrackingDriver(driverId: String, location: DriverLocation) async -> Result<Void, LocationError> {
        let data: [String: Any] = [
            "latitude": location.location.latitude,
            "longitude": location.location.longitude,
            "heading": location.heading,
            "speed": location.speed,
            "accuracy": location.accuracy,
            "timestamp": location.timestamp.timeIntervalSince1970
        ]
        
        let result = await realtimeDatabaseDataSource.setData(
            data,
            at: "driverLocations/\(driverId)"
        )
        
        return result.mapError { _ in .trackingFailed }
    }
    
    public func getDriverLocation(driverId: String) async -> Result<DriverLocation, LocationError> {
        let result = await realtimeDatabaseDataSource.getData(at: "driverLocations/\(driverId)")
        
        switch result {
        case .success(let data):
            guard let latitude = data["latitude"] as? Double,
                  let longitude = data["longitude"] as? Double,
                  let heading = data["heading"] as? Double,
                  let speed = data["speed"] as? Double,
                  let accuracy = data["accuracy"] as? Double,
                  let timestamp = data["timestamp"] as? TimeInterval else {
                return .failure(.invalidLocation)
            }
            
            let location = DriverLocation(
                driverId: driverId,
                location: GeoPoint(latitude: latitude, longitude: longitude),
                heading: heading,
                speed: speed,
                accuracy: accuracy,
                timestamp: Date(timeIntervalSince1970: timestamp)
            )
            
            return .success(location)
        case .failure:
            return .failure(.locationNotFound)
        }
    }
    
    public func stopTrackingDriver(driverId: String) async -> Result<Void, LocationError> {
        let result = await realtimeDatabaseDataSource.removeData(at: "driverLocations/\(driverId)")
        return result.mapError { _ in .trackingFailed }
    }
    
    public func subscribeToDriverLocation(driverId: String) -> AsyncStream<DriverLocation> {
        return AsyncStream { continuation in
            let stream = realtimeDatabaseDataSource.observeData(at: "driverLocations/\(driverId)")
            
            Task {
                for await data in stream {
                    guard let latitude = data["latitude"] as? Double,
                          let longitude = data["longitude"] as? Double,
                          let heading = data["heading"] as? Double,
                          let speed = data["speed"] as? Double,
                          let accuracy = data["accuracy"] as? Double,
                          let timestamp = data["timestamp"] as? TimeInterval else {
                        continue
                    }
                    
                    let location = DriverLocation(
                        driverId: driverId,
                        location: GeoPoint(latitude: latitude, longitude: longitude),
                        heading: heading,
                        speed: speed,
                        accuracy: accuracy,
                        timestamp: Date(timeIntervalSince1970: timestamp)
                    )
                    
                    continuation.yield(location)
                }
            }
        }
    }
}
