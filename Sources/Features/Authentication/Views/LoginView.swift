import SwiftUI

public struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignUp = false
    
    public init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Hamrah")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Daily Carpool Platform")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Enter your email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    SecureField("Enter your password", text: $password)
                        .textContentType(.password)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Sign In Button
                Button(action: {
                    Task {
                        await viewModel.signInWithEmail(email: email, password: password)
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.isLoading)
                
                // Sign Up Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    NavigationLink("Sign Up", destination: SignUpView(viewModel: viewModel))
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding(20)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
}
