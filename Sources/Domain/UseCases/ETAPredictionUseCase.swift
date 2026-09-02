import Foundation

public protocol ETAPredictionUseCase {
    func predictETA(from: GeoPoint, to: GeoPoint, atTime: Date) async -> Result<Int, RouteError>
    func updateETAWithTraffic(baseETA: Int, currentLocation: GeoPoint, destination: GeoPoint) async -> Result<Int, RouteError>
}

public final class DefaultETAPredictionUseCase: ETAPredictionUseCase {
    private let averageSpeedKmH = 40.0 // Average urban speed
    
    public func predictETA(from: GeoPoint, to: GeoPoint, atTime: Date) async -> Result<Int, RouteError> {
        let distance = haversineDistance(
            lat1: from.latitude,
            lon1: from.longitude,
            lat2: to.latitude,
            lon2: to.longitude
        )
        
        // Base calculation: distance / speed
        var baseTimeMinutes = (distance / averageSpeedKmH) * 60.0
        
        // Adjust for time of day (peak hours)
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: atTime)
        
        if (hour >= 7 && hour < 9) || (hour >= 17 && hour < 19) {
            baseTimeMinutes *= 1.5 // 50% increase during peak hours
        }
        
        return .success(Int(baseTimeMinutes))
    }
    
    public func updateETAWithTraffic(baseETA: Int, currentLocation: GeoPoint, destination: GeoPoint) async -> Result<Int, RouteError> {
        // Placeholder for real-time traffic API integration
        // Would call Google Maps Distance Matrix API or similar
        return .success(baseETA)
    }
    
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0
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
