import Foundation

public protocol BookingUseCase {
    func createBooking(passengerId: String, driverId: String, routeId: String, passengers: Int) async -> Result<Booking, BookingError>
    func updateBookingStatus(bookingId: String, status: BookingStatus) async -> Result<Booking, BookingError>
    func getPassengerBookings(passengerId: String) async -> Result<[Booking], BookingError>
    func getDriverBookings(driverId: String) async -> Result<[Booking], BookingError>
    func cancelBooking(bookingId: String) async -> Result<Void, BookingError>
}

public final class DefaultBookingUseCase: BookingUseCase {
    private let bookingRepository: BookingRepository
    private let costCalculationUseCase: CostCalculationUseCase
    
    public init(
        bookingRepository: BookingRepository,
        costCalculationUseCase: CostCalculationUseCase
    ) {
        self.bookingRepository = bookingRepository
        self.costCalculationUseCase = costCalculationUseCase
    }
    
    public func createBooking(passengerId: String, driverId: String, routeId: String, passengers: Int) async -> Result<Booking, BookingError> {
        let bookingId = UUID().uuidString
        let now = Date()
        
        let costResult = await costCalculationUseCase.calculateCost(
            distance: 10.0, // Placeholder - should come from route
            passengers: passengers,
            timeOfDay: now
        )
        
        guard case .success(let costPerPassenger) = costResult else {
            return .failure(.creationFailed)
        }
        
        let booking = Booking(
            id: bookingId,
            passengerId: passengerId,
            driverId: driverId,
            vehicleId: "", // To be populated
            routeId: routeId,
            status: .pending,
            pickupLocation: GeoPoint(latitude: 0, longitude: 0),
            dropoffLocation: GeoPoint(latitude: 0, longitude: 0),
            pickupAddress: "",
            dropoffAddress: "",
            scheduleDate: now,
            estimatedPickupTime: now.addingMinutes(10),
            estimatedDropoffTime: now.addingMinutes(20),
            passengers: passengers,
            costPerPassenger: costPerPassenger,
            totalCost: costPerPassenger * Double(passengers)
        )
        
        return await bookingRepository.createBooking(booking)
    }
    
    public func updateBookingStatus(bookingId: String, status: BookingStatus) async -> Result<Booking, BookingError> {
        let result = await bookingRepository.getBooking(bookingId: bookingId)
        
        guard case .success(var booking) = result else {
            return .failure(.updateFailed)
        }
        
        booking.status = status
        return await bookingRepository.updateBooking(booking)
    }
    
    public func getPassengerBookings(passengerId: String) async -> Result<[Booking], BookingError> {
        return await bookingRepository.getPassengerBookings(passengerId: passengerId)
    }
    
    public func getDriverBookings(driverId: String) async -> Result<[Booking], BookingError> {
        return await bookingRepository.getDriverBookings(driverId: driverId)
    }
    
    public func cancelBooking(bookingId: String) async -> Result<Void, BookingError> {
        return await bookingRepository.cancelBooking(bookingId: bookingId)
    }
}
