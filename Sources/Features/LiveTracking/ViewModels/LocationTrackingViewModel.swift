import Foundation
import Combine

@MainActor
public final class LocationTrackingViewModel: ObservableObject {
    @Published var driverLocation: DriverLocation?
    @Published var estimatedArrivalTime: Int = 0
    @Published var isTracking = false
    @Published var errorMessage: String?
    
    private let locationTrackingUseCase: LocationTrackingUseCase
    private let etaPredictionUseCase: ETAPredictionUseCase
    private var locationTask: Task<Void, Never>?
    
    public init(
        locationTrackingUseCase: LocationTrackingUseCase,
        etaPredictionUseCase: ETAPredictionUseCase
    ) {
        self.locationTrackingUseCase = locationTrackingUseCase
        self.etaPredictionUseCase = etaPredictionUseCase
    }
    
    func startTracking(driverId: String, destination: GeoPoint) async {
        isTracking = true
        errorMessage = nil
        
        _ = await locationTrackingUseCase.startTracking(driverId: driverId)
        
        locationTask = Task {
            let stream = self.locationTrackingUseCase.subscribeToDriverLocation(driverId: driverId)
            
            for await location in stream {
                await MainActor.run {
                    self.driverLocation = location
                    
                    Task {
                        let etaResult = await self.etaPredictionUseCase.predictETA(
                            from: location.location,
                            to: destination,
                            atTime: Date()
                        )
                        
                        await MainActor.run {
                            if case .success(let minutes) = etaResult {
                                self.estimatedArrivalTime = minutes
                            }
                        }
                    }
                }
            }
        }
    }
    
    func stopTracking(driverId: String) async {
        locationTask?.cancel()
        let result = await locationTrackingUseCase.stopTracking(driverId: driverId)
        
        await MainActor.run {
            isTracking = false
            switch result {
            case .success:
                self.driverLocation = nil
            case .failure(let error):
                self.errorMessage = error.errorDescription
            }
        }
    }
}
