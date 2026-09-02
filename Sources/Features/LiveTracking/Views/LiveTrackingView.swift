import SwiftUI
import MapKit

public struct LiveTrackingView: View {
    @StateObject private var viewModel: LocationTrackingViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3382, longitude: -121.8863),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    let driverId: String
    let destination: GeoPoint
    let passengerName: String
    
    public init(
        viewModel: LocationTrackingViewModel,
        driverId: String,
        destination: GeoPoint,
        passengerName: String
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.driverId = driverId
        self.destination = destination
        self.passengerName = passengerName
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Map
            ZStack(alignment: .topLeading) {
                Map(position: .constant(.region(region)))
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(passengerName)
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Arriving in \(viewModel.estimatedArrivalTime) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            if let speed = viewModel.driverLocation?.speed {
                                Text(String(format: "%.0f km/h", speed))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text("Speed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(.white)
                    .cornerRadius(8)
                }
                .padding(12)
            }
            
            // Details Panel
            VStack(spacing: 16) {
                if let location = viewModel.driverLocation {
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(location.location.latitude), \(location.location.longitude)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                
                NavigationLink(destination: ChatView(viewModel: ChatViewModel(messageRepository: MockMessageRepository(), encryptionService: AESEncryptionService.shared), senderId: driverId, recipientId: "", tripId: "")) {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                        Text("Message Driver")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call Driver")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(20)
            .background(.white)
        }
        .onAppear {
            Task {
                await viewModel.startTracking(driverId: driverId, destination: destination)
            }
        }
        .onDisappear {
            Task {
                await viewModel.stopTracking(driverId: driverId)
            }
        }
    }
}

// Mock implementation for preview
struct MockMessageRepository: MessageRepository {
    func sendMessage(_ message: Message) async -> Result<Message, MessageError> { .success(message) }
    func getMessage(messageId: String) async -> Result<Message, MessageError> { .failure(.messageNotFound) }
    func getConversation(senderId: String, recipientId: String) async -> Result<[Message], MessageError> { .success([]) }
    func markMessageAsRead(messageId: String) async -> Result<Void, MessageError> { .success(()) }
    func subscribeToMessages(userId: String) -> AsyncStream<Message> { AsyncStream { _ in } }
}
