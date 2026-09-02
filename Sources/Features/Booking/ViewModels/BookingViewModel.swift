import Foundation
import Combine

@MainActor
public final class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var selectedBooking: Booking?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var bookingStatus: BookingStatus = .pending
    
    private let bookingUseCase: BookingUseCase
    private let costCalculationUseCase: CostCalculationUseCase
    private let notificationUseCase: NotificationUseCase
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        bookingUseCase: BookingUseCase,
        costCalculationUseCase: CostCalculationUseCase,
        notificationUseCase: NotificationUseCase
    ) {
        self.bookingUseCase = bookingUseCase
        self.costCalculationUseCase = costCalculationUseCase
        self.notificationUseCase = notificationUseCase
    }
    
    func createBooking(passengerId: String, driverId: String, routeId: String, passengers: Int) async {
        isLoading = true
        errorMessage = nil
        
        let result = await bookingUseCase.createBooking(
            passengerId: passengerId,
            driverId: driverId,
            routeId: routeId,
            passengers: passengers
        )
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let booking):
                self.selectedBooking = booking
                self.bookingStatus = booking.status
                self.bookings.append(booking)
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func loadPassengerBookings(passengerId: String) async {
        isLoading = true
        errorMessage = nil
        
        let result = await bookingUseCase.getPassengerBookings(passengerId: passengerId)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let bookings):
                self.bookings = bookings
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func loadDriverBookings(driverId: String) async {
        isLoading = true
        errorMessage = nil
        
        let result = await bookingUseCase.getDriverBookings(driverId: driverId)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let bookings):
                self.bookings = bookings
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func updateBookingStatus(bookingId: String, status: BookingStatus) async {
        let result = await bookingUseCase.updateBookingStatus(bookingId: bookingId, status: status)
        
        await MainActor.run {
            switch result {
            case .success(let booking):
                self.selectedBooking = booking
                self.bookingStatus = booking.status
                if let index = self.bookings.firstIndex(where: { $0.id == booking.id }) {
                    self.bookings[index] = booking
                }
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func cancelBooking(bookingId: String) async {
        let result = await bookingUseCase.cancelBooking(bookingId: bookingId)
        
        await MainActor.run {
            switch result {
            case .success:
                self.bookings.removeAll { $0.id == bookingId }
                self.selectedBooking = nil
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
}
