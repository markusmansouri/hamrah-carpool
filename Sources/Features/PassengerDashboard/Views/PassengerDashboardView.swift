import SwiftUI

public struct PassengerDashboardView: View {
    @StateObject private var bookingViewModel: BookingViewModel
    @State private var showNewBooking = false
    
    let userId: String
    
    public init(bookingViewModel: BookingViewModel, userId: String) {
        _bookingViewModel = StateObject(wrappedValue: bookingViewModel)
        self.userId = userId
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Rides")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Manage your bookings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(.systemGray6))
                
                ScrollView {
                    VStack(spacing: 12) {
                        if bookingViewModel.bookings.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "car")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("No rides booked")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            ForEach(bookingViewModel.bookings) { booking in
                                BookingCardView(booking: booking)
                                    .onTapGesture {
                                        bookingViewModel.selectedBooking = booking
                                    }
                            }
                        }
                    }
                    .padding(20)
                }
                
                // Book Now Button
                Button(action: { showNewBooking = true }) {
                    Text("Book a Ride")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(20)
            }
            .sheet(isPresented: $showNewBooking) {
                RouteSearchView()
            }
            .task {
                await bookingViewModel.loadPassengerBookings(passengerId: userId)
            }
        }
    }
}

private struct BookingCardView: View {
    let booking: Booking
    
    var statusColor: Color {
        switch booking.status {
        case .pending, .confirmed: return .blue
        case .driverArrived, .inProgress: return .orange
        case .completed: return .green
        case .cancelled: return .red
        case .noShow: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.pickupAddress)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("to \(booking.dropoffAddress)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", booking.totalCost))")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(booking.status.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor)
                        .cornerRadius(4)
                }
            }
            
            Divider()
            
            HStack(spacing: 16) {
                Label(
                    DateFormatter.localizedString(from: booking.scheduleDate, dateStyle: .medium, timeStyle: .short),
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Label(
                    "\(booking.passengers) passenger\(booking.passengers > 1 ? "s" : "")",
                    systemImage: "person.fill"
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
