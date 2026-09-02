import SwiftUI

public struct SettingsView: View {
    @AppStorage("appLanguage") var appLanguage = "en"
    @State private var showLanguageSelector = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
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
                    Text(NSLocalizedString("settings.title", comment: ""))
                        .font(.headline)
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Language Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("settings.language.title", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Button(action: { showLanguageSelector = true }) {
                                HStack {
                                    Label(
                                        NSLocalizedString("settings.language.current", comment: ""),
                                        systemImage: "globe"
                                    )
                                    Spacer()
                                    Text(appLanguage == "sv" ? "Svenska" : "English")
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(.white)
                        .cornerRadius(8)
                        
                        // Notifications Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("settings.notifications.title", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Toggle(
                                NSLocalizedString("settings.notifications.enable", comment: ""),
                                isOn: $notificationsEnabled
                            )
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(16)
                        .background(.white)
                        .cornerRadius(8)
                        
                        // Appearance Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("settings.appearance.title", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Toggle(
                                NSLocalizedString("settings.appearance.dark", comment: ""),
                                isOn: $darkModeEnabled
                            )
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(16)
                        .background(.white)
                        .cornerRadius(8)
                        
                        // App Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("settings.about.title", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(NSLocalizedString("settings.app.version", comment: ""))
                                    Spacer()
                                    Text("1.0.0")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text(NSLocalizedString("settings.app.build", comment: ""))
                                    Spacer()
                                    Text("1")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(16)
                        .background(.white)
                        .cornerRadius(8)
                    }
                    .padding(16)
                }
            }
        }
    }
}
