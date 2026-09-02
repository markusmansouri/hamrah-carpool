import SwiftUI

public struct SignUpView: View {
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedRole: UserRole = .passenger
    
    public init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                Spacer()
                Text("Create Account")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 16) {
                    // First Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("First name", text: $firstName)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Last Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Last name", text: $lastName)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Role Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("I want to")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Picker("Role", selection: $selectedRole) {
                            Text("Ride as Passenger").tag(UserRole.passenger)
                            Text("Drive Others").tag(UserRole.driver)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Sign Up Button
                    Button(action: {
                        Task {
                            await viewModel.signUpWithEmail(
                                email: email,
                                password: password,
                                firstName: firstName,
                                lastName: lastName
                            )
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading)
                }
                .padding(20)
            }
            
            Spacer()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}
