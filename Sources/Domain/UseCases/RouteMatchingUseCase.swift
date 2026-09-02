import Foundation

public protocol RouteMatchingUseCase {
    func findMatchingRoutes(home: GeoPoint, work: GeoPoint, tolerance: Double) async -> Result<[Route], RouteError>
    func calculateRouteSimilarity(route1: Route, route2: Route) -> Double
    func getOptimalRoute(from routes: [Route], for destination: GeoPoint) -> Route?
}

public final class DefaultRouteMatchingUseCase: RouteMatchingUseCase {
    private let routeRepository: RouteRepository
    
    public init(routeRepository: RouteRepository) {
        self.routeRepository = routeRepository
    }
    
    public func findMatchingRoutes(home: GeoPoint, work: GeoPoint, tolerance: Double) async -> Result<[Route], RouteError> {
        return await routeRepository.searchRoutes(home: home, work: work, tolerance: tolerance)
    }
    
    public func calculateRouteSimilarity(route1: Route, route2: Route) -> Double {
        let homeDistance = haversineDistance(
            lat1: route1.homeLocation.latitude,
            lon1: route1.homeLocation.longitude,
            lat2: route2.homeLocation.latitude,
            lon2: route2.homeLocation.longitude
        )
        
        let workDistance = haversineDistance(
            lat1: route1.workplaceLocation.latitude,
            lon1: route1.workplaceLocation.longitude,
            lat2: route2.workplaceLocation.latitude,
            lon2: route2.workplaceLocation.longitude
        )
        
        // Tolerance for similarity: 2 km
        let tolerance: Double = 2.0
        
        if homeDistance <= tolerance && workDistance <= tolerance {
            return 1.0
        }
        
        let maxDistance: Double = 10.0
        let similarity = max(0, 1.0 - (max(homeDistance, workDistance) / maxDistance))
        return similarity
    }
    
    public func getOptimalRoute(from routes: [Route], for destination: GeoPoint) -> Route? {
        routes.max { route1, route2 in
            haversineDistance(
                lat1: route1.workplaceLocation.latitude,
                lon1: route1.workplaceLocation.longitude,
                lat2: destination.latitude,
                lon2: destination.longitude
            ) < haversineDistance(
                lat1: route2.workplaceLocation.latitude,
                lon1: route2.workplaceLocation.longitude,
                lat2: destination.latitude,
                lon2: destination.longitude
            )
        }
    }
    
    // MARK: - Private Helpers
    
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0 // Earth's radius in kilometers
        
        let lat1Rad = lat1 * .pi / 180.0
        let lat2Rad = lat2 * .pi / 180.0
        let deltaLat = (lat2 - lat1) * .pi / 180.0
        let deltaLon = (lon2 - lon1) * .pi / 180.0
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLon / 2) * sin(deltaLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}
