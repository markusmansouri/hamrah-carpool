import SwiftUI

public struct MainTabView: View {
    @StateObject private var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    let userId: String
    let userRole: UserRole
    
    public init(
        authViewModel: AuthViewModel,
        userId: String,
        userRole: UserRole
    ) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        self.userId = userId
        self.userRole = userRole
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            if userRole == .driver || userRole == .both {
                DriverDashboardView(
                    viewModel: DriverDashboardViewModel(
                        driverRepository: MockDriverRepository(),
                        bookingRepository: MockBookingRepository()
                    ),
                    driverId: userId
                )
                .tabItem {
                    Label(NSLocalizedString("driver.dashboard.title", comment: ""), systemImage: "car.fill")
                }
                .tag(0)
            } else {
                PassengerDashboardView(
                    bookingViewModel: BookingViewModel(
                        bookingUseCase: MockBookingUseCase(),
                        costCalculationUseCase: MockCostCalculationUseCase(),
                        notificationUseCase: MockNotificationUseCase()
                    ),
                    userId: userId
                )
                .tabItem {
                    Label(NSLocalizedString("passenger.dashboard.title", comment: ""), systemImage: "car")
                }
                .tag(0)
            }
            
            // History Tab
            Text(NSLocalizedString("common.cancel", comment: ""))
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
            
            // Messages Tab
            Text("Messages")
                .tabItem {
                    Label(NSLocalizedString("message.title", comment: ""), systemImage: "bubble.left.fill")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

// Mock implementations
struct MockDriverRepository: DriverRepository {
    func registerDriver(_ driver: Driver) async -> Result<Driver, DriverError> { .success(driver) }
    func getDriver(driverId: String) async -> Result<Driver, DriverError> { .failure(.driverNotFound) }
    func updateDriver(_ driver: Driver) async -> Result<Driver, DriverError> { .success(driver) }
    func getActiveDrivers() async -> Result<[Driver], DriverError> { .success([]) }
    func getDriversByRoute(routeId: String) async -> Result<[Driver], DriverError> { .success([]) }
}

struct MockBookingRepository: BookingRepository {
    func createBooking(_ booking: Booking) async -> Result<Booking, BookingError> { .success(booking) }
    func getBooking(bookingId: String) async -> Result<Booking, BookingError> { .failure(.bookingNotFound) }
    func updateBooking(_ booking: Booking) async -> Result<Booking, BookingError> { .success(booking) }
    func getPassengerBookings(passengerId: String) async -> Result<[Booking], BookingError> { .success([]) }
    func getDriverBookings(driverId: String) async -> Result<[Booking], BookingError> { .success([]) }
    func cancelBooking(bookingId: String) async -> Result<Void, BookingError> { .success(()) }
}

struct MockBookingUseCase: BookingUseCase {
    func createBooking(passengerId: String, driverId: String, routeId: String, passengers: Int) async -> Result<Booking, BookingError> { .failure(.creationFailed) }
    func updateBookingStatus(bookingId: String, status: BookingStatus) async -> Result<Booking, BookingError> { .failure(.updateFailed) }
    func getPassengerBookings(passengerId: String) async -> Result<[Booking], BookingError> { .success([]) }
    func getDriverBookings(driverId: String) async -> Result<[Booking], BookingError> { .success([]) }
    func cancelBooking(bookingId: String) async -> Result<Void, BookingError> { .success(()) }
}

struct MockCostCalculationUseCase: CostCalculationUseCase {
    func calculateCost(distance: Double, passengers: Int, timeOfDay: Date) async -> Result<Double, BookingError> { .success(10.0) }
    func calculateTotalCost(costPerPassenger: Double, passengers: Int) -> Double { costPerPassenger * Double(passengers) }
    func applyPromotionalDiscount(cost: Double, code: String) -> Double { cost }
}

struct MockNotificationUseCase: NotificationUseCase {
    func sendPickupReminder(booking: Booking) async -> Result<Void, NotificationError> { .success(()) }
    func sendDelayAlert(booking: Booking, delayMinutes: Int) async -> Result<Void, NotificationError> { .success(()) }
    func sendRideStartedNotification(booking: Booking) async -> Result<Void, NotificationError> { .success(()) }
    func sendRideCompletedNotification(booking: Booking) async -> Result<Void, NotificationError> { .success(()) }
}
