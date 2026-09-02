import Foundation

public protocol AuthUseCase {
    func signUpWithEmail(email: String, password: String, user: User) async -> Result<User, AuthError>
    func signUpWithPhone(phoneNumber: String, user: User) async -> Result<User, AuthError>
    func signInWithEmail(email: String, password: String) async -> Result<User, AuthError>
    func signInWithPhone(phoneNumber: String, code: String) async -> Result<User, AuthError>
    func signOut() async -> Result<Void, AuthError>
    func getCurrentUser() async -> Result<User?, AuthError>
    func sendPhoneVerificationCode(phoneNumber: String) async -> Result<Void, AuthError>
}

public final class DefaultAuthUseCase: AuthUseCase {
    private let authRepository: AuthRepository
    
    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    public func signUpWithEmail(email: String, password: String, user: User) async -> Result<User, AuthError> {
        guard email.isValidEmail else { return .failure(.invalidEmail) }
        guard password.count >= 8 else { return .failure(.invalidPassword) }
        
        return await authRepository.signUpWithEmail(email: email, password: password, user: user)
    }
    
    public func signUpWithPhone(phoneNumber: String, user: User) async -> Result<User, AuthError> {
        guard phoneNumber.isValidPhoneNumber else { return .failure(.invalidPassword) }
        
        return await authRepository.signUpWithPhone(phoneNumber: phoneNumber, user: user)
    }
    
    public func signInWithEmail(email: String, password: String) async -> Result<User, AuthError> {
        guard email.isValidEmail else { return .failure(.invalidEmail) }
        
        return await authRepository.signInWithEmail(email: email, password: password)
    }
    
    public func signInWithPhone(phoneNumber: String, code: String) async -> Result<User, AuthError> {
        guard phoneNumber.isValidPhoneNumber else { return .failure(.invalidPassword) }
        guard code.count == 6 else { return .failure(.invalidCode) }
        
        return await authRepository.signInWithPhone(phoneNumber: phoneNumber, code: code)
    }
    
    public func signOut() async -> Result<Void, AuthError> {
        return await authRepository.signOut()
    }
    
    public func getCurrentUser() async -> Result<User?, AuthError> {
        return await authRepository.getCurrentUser()
    }
    
    public func sendPhoneVerificationCode(phoneNumber: String) async -> Result<Void, AuthError> {
        guard phoneNumber.isValidPhoneNumber else { return .failure(.invalidPassword) }
        
        return await authRepository.sendPhoneVerificationCode(phoneNumber: phoneNumber)
    }
}
