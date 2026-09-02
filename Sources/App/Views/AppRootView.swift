import SwiftUI

public struct AppRootView: View {
    @StateObject private var authViewModel: AuthViewModel
    @AppStorage("appLanguage") var appLanguage = "en"
    
    public init(authViewModel: AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }
    
    public var body: some View {
        Group {
            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                MainTabView(
                    authViewModel: authViewModel,
                    userId: user.id,
                    userRole: user.role
                )
            } else {
                WelcomeView(viewModel: authViewModel)
            }
        }
        .environment(\.locale, Locale(identifier: appLanguage))
    }
}
