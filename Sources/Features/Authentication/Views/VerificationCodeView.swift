import SwiftUI

public struct VerificationCodeView: View {
    @StateObject private var authViewModel: AuthViewModel
    @State private var codes: [String] = ["", "", "", "", "", ""]
    @FocusState private var focusedIndex: Int?
    @Environment(\.dismiss) var dismiss
    
    let phoneNumber: String
    
    public init(authViewModel: AuthViewModel, phoneNumber: String) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        self.phoneNumber = phoneNumber
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text(NSLocalizedString("verification.title", comment: ""))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(String(format: NSLocalizedString("verification.subtitle", comment: ""), phoneNumber))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Code Input Fields
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $codes[index])
                        .frame(height: 48)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.numberPad)
                        .focused($focusedIndex, equals: index)
                        .onChange(of: codes[index]) { _, newValue in
                            // Allow only one digit
                            if newValue.count > 1 {
                                codes[index] = String(newValue.prefix(1))
                            }
                            
                            // Move to next field
                            if !newValue.isEmpty && index < 5 {
                                focusedIndex = index + 1
                            }
                        }
                        .onDeleteBackward {
                            if index > 0 {
                                focusedIndex = index - 1
                            }
                        }
                }
            }
            
            // Verify Button
            Button(action: {
                let code = codes.joined()
                Task {
                    // Verify code
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(NSLocalizedString("verification.button", comment: ""))
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(authViewModel.isLoading || codes.contains(""))
            
            // Resend Code
            HStack(spacing: 4) {
                Text(NSLocalizedString("verification.resend.text", comment: ""))
                    .foregroundColor(.secondary)
                
                Button(action: {}) {
                    Text(NSLocalizedString("verification.resend.button", comment: ""))
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            .font(.subheadline)
            
            Spacer()
        }
        .padding(20)
        .navigationBarBackButtonHidden(false)
    }
}
