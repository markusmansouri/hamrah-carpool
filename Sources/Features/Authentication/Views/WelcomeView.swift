import SwiftUI

public struct WelcomeView: View {
    @StateObject private var authViewModel: AuthViewModel
    @State private var showLogin = false
    @State private var showSignUp = false
    
    public init(authViewModel: AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeadingtoLeadingToBottomTrailing,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "car.2.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text(NSLocalizedString("welcome.title", comment: ""))
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            Text(NSLocalizedString("welcome.subtitle", comment: ""))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(NSLocalizedString("welcome.feature.1", comment: ""))
                                .font(.subheadline)
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(NSLocalizedString("welcome.feature.2", comment: ""))
                                .font(.subheadline)
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(NSLocalizedString("welcome.feature.3", comment: ""))
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: LoginView(viewModel: authViewModel)) {
                            Text(NSLocalizedString("welcome.login.button", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        NavigationLink(destination: SignUpView(viewModel: authViewModel)) {
                            Text(NSLocalizedString("welcome.signup.button", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(20)
            }
        }
    }
}

extension LinearGradient {
    static let startPoint = UnitPoint.topLeading
    static let endPoint = UnitPoint.bottomTrailing
}
