import SwiftUI

public struct NotificationsView: View {
    @State private var notifications: [NotificationItem] = [
        NotificationItem(id: "1", title: "Driver Arrived", message: "Your driver is here", timestamp: Date(), icon: "car.fill", iconColor: .blue),
        NotificationItem(id: "2", title: "Booking Confirmed", message: "Your ride has been confirmed", timestamp: Date().addingTimeInterval(-3600), icon: "checkmark.circle.fill", iconColor: .green),
    ]
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
                    Text(NSLocalizedString("notifications.title", comment: ""))
                        .font(.headline)
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                
                if notifications.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text(NSLocalizedString("notifications.empty", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(notifications) { notification in
                                NotificationRowView(notification: notification)
                                    .onTapGesture {
                                        // Handle notification tap
                                    }
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }
}

private struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let icon: String
    let iconColor: Color
}

private struct NotificationRowView: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.icon)
                .font(.system(size: 20))
                .foregroundColor(notification.iconColor)
                .frame(width: 40, height: 40)
                .background(notification.iconColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(timeAgo(notification.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}
