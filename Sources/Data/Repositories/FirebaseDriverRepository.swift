import Foundation

public final class FirebaseDriverRepository: DriverRepository {
    private let firestoreDataSource: FirestoreDataSource
    
    public init(firestoreDataSource: FirestoreDataSource) {
        self.firestoreDataSource = firestoreDataSource
    }
    
    public func registerDriver(_ driver: Driver) async -> Result<Driver, DriverError> {
        let result = await firestoreDataSource.setDocument(
            driver,
            at: "drivers/\(driver.id)"
        )
        return result.map { driver }.mapError { _ in .registrationFailed }
    }
    
    public func getDriver(driverId: String) async -> Result<Driver, DriverError> {
        let result: Result<Driver, DataError> = await firestoreDataSource.getDocument(
            "drivers/\(driverId)",
            as: Driver.self
        )
        return result.mapError { _ in .driverNotFound }
    }
    
    public func updateDriver(_ driver: Driver) async -> Result<Driver, DriverError> {
        let data: [String: Any] = [
            "licenseNumber": driver.licenseNumber,
            "licenseExpiry": driver.licenseExpiry,
            "isLicenseVerified": driver.isLicenseVerified,
            "backgroundCheckPassed": driver.backgroundCheckPassed,
            "averageRating": driver.averageRating,
            "isActive": driver.isActive
        ]
        
        let result = await firestoreDataSource.updateDocument(
            data,
            at: "drivers/\(driver.id)"
        )
        
        return result.map { driver }.mapError { _ in .updateFailed }
    }
    
    public func getActiveDrivers() async -> Result<[Driver], DriverError> {
        let result: Result<[Driver], DataError> = await firestoreDataSource.queryDocuments(
            "drivers",
            whereField: "isActive",
            isEqualTo: true,
            as: Driver.self
        )
        return result.mapError { _ in .driverNotFound }
    }
    
    public func getDriversByRoute(routeId: String) async -> Result<[Driver], DriverError> {
        // In production, would query drivers whose routes match the given routeId
        let result: Result<[Driver], DataError> = await firestoreDataSource.queryDocuments(
            "drivers",
            whereField: "isActive",
            isEqualTo: true,
            as: Driver.self
        )
        return result.mapError { _ in .driverNotFound }
    }
}
