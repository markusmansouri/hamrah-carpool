import SwiftUI

public struct ProfileView: View {
    @State private var user: User?
    @State private var isEditing = false
    @State private var editedFirstName = ""
    @State private var editedLastName = ""
    @State private var showSettings = false
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(NSLocalizedString("common.back", comment: ""))
                        }
                    }
                    Spacer()
                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Image
                        VStack(spacing: 12) {
                            if let user = user, let imageUrl = user.profileImageUrl {
                                AsyncImage(url: URL(string: imageUrl)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    default:
                                        Image(systemName: "person.crop.circle.fill")
                                            .font(.system(size: 100))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 100))
                                    .foregroundColor(.secondary)
                            }
                            
                            if isEditing {
                                Button(NSLocalizedString("profile.change.photo", comment: "")) {}
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Profile Information
                        VStack(alignment: .leading, spacing: 16) {
                            // First Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("common.firstName", comment: ""))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if isEditing {
                                    TextField("", text: $editedFirstName)
                                        .padding(12)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                } else {
                                    Text(user?.firstName ?? "")
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                            
                            // Last Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("common.lastName", comment: ""))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if isEditing {
                                    TextField("", text: $editedLastName)
                                        .padding(12)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                } else {
                                    Text(user?.lastName ?? "")
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("common.email", comment: ""))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(user?.email ?? "")
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            // Rating
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("profile.rating", comment: ""))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack(spacing: 4) {
                                    ForEach(0..<5, id: \.self) { index in
                                        Image(systemName: index < Int(user?.rating ?? 0) ? "star.fill" : "star")
                                            .font(.system(size: 16))
                                            .foregroundColor(.yellow)
                                    }
                                    Text(String(format: "%.1f", user?.rating ?? 0))
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(.white)
                        .cornerRadius(8)
                        
                        // Settings Section
                        NavigationLink(destination: SettingsView()) {
                            HStack {
                                Label(
                                    NSLocalizedString("profile.settings", comment: ""),
                                    systemImage: "gearshape.fill"
                                )
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}
