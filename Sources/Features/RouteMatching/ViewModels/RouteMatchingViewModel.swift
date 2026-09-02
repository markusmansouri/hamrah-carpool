import Foundation
import Combine

@MainActor
public final class RouteMatchingViewModel: ObservableObject {
    @Published var availableRoutes: [Route] = []
    @Published var selectedRoute: Route?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let routeMatchingUseCase: RouteMatchingUseCase
    private let routeRepository: RouteRepository
    
    public init(
        routeMatchingUseCase: RouteMatchingUseCase,
        routeRepository: RouteRepository
    ) {
        self.routeMatchingUseCase = routeMatchingUseCase
        self.routeRepository = routeRepository
    }
    
    func searchMatches(home: GeoPoint, work: GeoPoint) async {
        isLoading = true
        errorMessage = nil
        
        let result = await routeMatchingUseCase.findMatchingRoutes(
            home: home,
            work: work,
            tolerance: 2.0
        )
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let routes):
                self.availableRoutes = routes.sorted { route1, route2 in
                    let similarity1 = self.routeMatchingUseCase.calculateRouteSimilarity(route1: route1, route2: Route(id: "", userId: "", routeType: .morning, homeLocation: home, workplaceLocation: work, homeAddress: "", workplaceAddress: "", departureTime: "", returnTime: "", weekdays: [], estimatedDuration: 0, estimatedDistance: 0, polylinePoints: []))
                    let similarity2 = self.routeMatchingUseCase.calculateRouteSimilarity(route1: route2, route2: Route(id: "", userId: "", routeType: .morning, homeLocation: home, workplaceLocation: work, homeAddress: "", workplaceAddress: "", departureTime: "", returnTime: "", weekdays: [], estimatedDuration: 0, estimatedDistance: 0, polylinePoints: []))
                    return similarity1 > similarity2
                }
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func selectRoute(_ route: Route) {
        selectedRoute = route
    }
}
