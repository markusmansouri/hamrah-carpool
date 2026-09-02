import Foundation
import Combine

@MainActor
public final class DriverDashboardViewModel: ObservableObject {
    @Published var driver: Driver?
    @Published var upcomingBookings: [Booking] = []
    @Published var todayEarnings: Double = 0.0
    @Published var monthlyTrips: Int = 0
    @Published var averageRating: Double = 0.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let driverRepository: DriverRepository
    private let bookingRepository: BookingRepository
    
    public init(
        driverRepository: DriverRepository,
        bookingRepository: BookingRepository
    ) {
        self.driverRepository = driverRepository
        self.bookingRepository = bookingRepository
    }
    
    func loadDriverInfo(driverId: String) async {
        isLoading = true
        errorMessage = nil
        
        let result = await driverRepository.getDriver(driverId: driverId)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let driver):
                self.driver = driver
                self.averageRating = driver.averageRating
            case .failure(let error):
                self.errorMessage = error.errorDescription
            }
        }
    }
    
    func loadUpcomingBookings(driverId: String) async {
        let result = await bookingRepository.getDriverBookings(driverId: driverId)
        
        await MainActor.run {
            switch result {
            case .success(let bookings):
                self.upcomingBookings = bookings.filter {
                    $0.status == .pending || $0.status == .confirmed
                }
            case .failure(let error):
                self.errorMessage = error.errorDescription
            }
        }
    }
}
