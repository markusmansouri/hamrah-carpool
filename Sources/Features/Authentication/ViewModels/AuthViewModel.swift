import Foundation
import Combine

@MainActor
public final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let authUseCase: AuthUseCase
    private var cancellables = Set<AnyCancellable>()
    
    public init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
        Task {
            await checkCurrentUser()
        }
    }
    
    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String) async {
        isLoading = true
        errorMessage = nil
        
        let user = User(
            id: UUID().uuidString,
            email: email,
            phoneNumber: "",
            firstName: firstName,
            lastName: lastName,
            role: .passenger
        )
        
        let result = await authUseCase.signUpWithEmail(email: email, password: password, user: user)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let user):
                self.currentUser = user
                self.isAuthenticated = true
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func signUpWithPhone(phoneNumber: String, firstName: String, lastName: String) async {
        isLoading = true
        errorMessage = nil
        
        let result = await authUseCase.sendPhoneVerificationCode(phoneNumber: phoneNumber)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success:
                // Navigate to verification screen
                break
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        let result = await authUseCase.signInWithEmail(email: email, password: password)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let user):
                self.currentUser = user
                self.isAuthenticated = true
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func signOut() async {
        let result = await authUseCase.signOut()
        
        await MainActor.run {
            switch result {
            case .success:
                self.currentUser = nil
                self.isAuthenticated = false
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    private func checkCurrentUser() async {
        let result = await authUseCase.getCurrentUser()
        
        await MainActor.run {
            switch result {
            case .success(let user):
                self.currentUser = user
                self.isAuthenticated = user != nil
            case .failure:
                self.isAuthenticated = false
            }
        }
    }
}
