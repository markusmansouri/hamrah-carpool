import Foundation

public protocol LocationTrackingUseCase {
    func startTracking(driverId: String) async -> Result<Void, LocationError>
    func stopTracking(driverId: String) async -> Result<Void, LocationError>
    func getLatestDriverLocation(driverId: String) async -> Result<DriverLocation, LocationError>
    func subscribeToDriverLocation(driverId: String) -> AsyncStream<DriverLocation>
}

public final class DefaultLocationTrackingUseCase: LocationTrackingUseCase {
    private let locationRepository: LocationRepository
    
    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }
    
    public func startTracking(driverId: String) async -> Result<Void, LocationError> {
        // Location manager would handle actual GPS tracking
        return .success(())
    }
    
    public func stopTracking(driverId: String) async -> Result<Void, LocationError> {
        return await locationRepository.stopTrackingDriver(driverId: driverId)
    }
    
    public func getLatestDriverLocation(driverId: String) async -> Result<DriverLocation, LocationError> {
        return await locationRepository.getDriverLocation(driverId: driverId)
    }
    
    public func subscribeToDriverLocation(driverId: String) -> AsyncStream<DriverLocation> {
        return locationRepository.subscribeToDriverLocation(driverId: driverId)
    }
}
