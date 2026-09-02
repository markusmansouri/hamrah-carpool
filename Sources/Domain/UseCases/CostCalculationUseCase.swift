import Foundation

public protocol CostCalculationUseCase {
    func calculateCost(distance: Double, passengers: Int, timeOfDay: Date) async -> Result<Double, BookingError>
    func calculateTotalCost(costPerPassenger: Double, passengers: Int) -> Double
    func applyPromotionalDiscount(cost: Double, code: String) -> Double
}

public final class DefaultCostCalculationUseCase: CostCalculationUseCase {
    private let baseCostPerKm = 0.5 // Currency units per km
    private let baseCostPerMinute = 0.1
    
    public func calculateCost(distance: Double, passengers: Int, timeOfDay: Date) async -> Result<Double, BookingError> {
        let baseCost = (distance * baseCostPerKm) + (distance / 50.0 * 60.0 * baseCostPerMinute)
        
        // Peak hours multiplier: 7-9 AM and 5-7 PM
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: timeOfDay)
        let peakMultiplier: Double = (hour >= 7 && hour < 9) || (hour >= 17 && hour < 19) ? 1.25 : 1.0
        
        // Passenger discount: More passengers = lower per-passenger cost
        let passengerDiscount = max(0.8, 1.0 - (Double(passengers - 1) * 0.1))
        
        let costPerPassenger = (baseCost * peakMultiplier * passengerDiscount).rounded(toPlaces: 2)
        
        return .success(costPerPassenger)
    }
    
    public func calculateTotalCost(costPerPassenger: Double, passengers: Int) -> Double {
        (costPerPassenger * Double(passengers)).rounded(toPlaces: 2)
    }
    
    public func applyPromotionalDiscount(cost: Double, code: String) -> Double {
        // Placeholder for promotional code logic
        let discount = code.contains("SAVE") ? 0.1 : 0.0
        return (cost * (1.0 - discount)).rounded(toPlaces: 2)
    }
}
