import SwiftUI

public struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(NSLocalizedString("common.back", comment: ""))
                    }
                }
                Spacer()
            }
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("forgotpassword.title", comment: ""))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(NSLocalizedString("forgotpassword.subtitle", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("common.email", comment: ""))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField(NSLocalizedString("common.email.placeholder", comment: ""), text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Send Button
            Button(action: {}) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(NSLocalizedString("forgotpassword.send.button", comment: ""))
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(email.isEmpty || isLoading)
            
            Spacer()
        }
        .padding(20)
        .alert(NSLocalizedString("forgotpassword.success.title", comment: ""), isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text(NSLocalizedString("forgotpassword.success.message", comment: ""))
        }
    }
}
