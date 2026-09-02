import SwiftUI

public struct DriverDashboardView: View {
    @StateObject private var viewModel: DriverDashboardViewModel
    @State private var showAddRoute = false
    
    let driverId: String
    
    public init(viewModel: DriverDashboardViewModel, driverId: String) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.driverId = driverId
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Driver Dashboard")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        StatCard(title: "Today's Earnings", value: "$\(String(format: "%.2f", viewModel.todayEarnings))")
                        StatCard(title: "Rating", value: String(format: "%.1f", viewModel.averageRating))
                        StatCard(title: "Trips", value: "\(viewModel.monthlyTrips)")
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Upcoming Bookings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming Rides")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if viewModel.upcomingBookings.isEmpty {
                                Text("No upcoming bookings")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(24)
                            } else {
                                ForEach(viewModel.upcomingBookings) { booking in
                                    DriverBookingRowView(booking: booking)
                                }
                            }
                        }
                        
                        // Add Route Button
                        Button(action: { showAddRoute = true }) {
                            Label("Add Daily Route", systemImage: "plus.circle.fill")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(20)
                }
            }
            .sheet(isPresented: $showAddRoute) {
                AddRouteView()
            }
            .task {
                await viewModel.loadDriverInfo(driverId: driverId)
                await viewModel.loadUpcomingBookings(driverId: driverId)
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white)
        .cornerRadius(8)
    }
}

private struct DriverBookingRowView: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pickup: \(booking.pickupAddress)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Dropoff: \(booking.dropoffAddress)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", booking.totalCost))")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("\(booking.passengers) seats")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
