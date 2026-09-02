import Foundation
import FirebaseMessaging

public protocol PushNotificationDataSource {
    func requestUserNotificationPermission() async -> Bool
    func sendNotification(_ title: String, body: String, to userId: String) async -> Result<Void, NotificationDataSourceError>
    func subscribeToTopic(_ topic: String) async -> Result<Void, NotificationDataSourceError>
    func unsubscribeFromTopic(_ topic: String) async -> Result<Void, NotificationDataSourceError>
}

public enum NotificationDataSourceError: LocalizedError {
    case permissionDenied
    case sendFailed
    case subscriptionFailed
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Notification permission denied"
        case .sendFailed: return "Failed to send notification"
        case .subscriptionFailed: return "Failed to subscribe to topic"
        case .unknown(let message): return message
        }
    }
}

public final class FirebaseMessagingDataSource: NSObject, PushNotificationDataSource {
    public static let shared = FirebaseMessagingDataSource()
    
    private override init() {
        super.init()
        Messaging.messaging().delegate = self
    }
    
    public func requestUserNotificationPermission() async -> Bool {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return true
        } catch {
            return false
        }
    }
    
    public func sendNotification(_ title: String, body: String, to userId: String) async -> Result<Void, NotificationDataSourceError> {
        // This would typically be called from Cloud Functions
        // Client apps receive notifications, they don't send them
        return .success(())
    }
    
    public func subscribeToTopic(_ topic: String) async -> Result<Void, NotificationDataSourceError> {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("Failed to subscribe to topic: \(error.localizedDescription)")
            }
        }
        return .success(())
    }
    
    public func unsubscribeFromTopic(_ topic: String) async -> Result<Void, NotificationDataSourceError> {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("Failed to unsubscribe from topic: \(error.localizedDescription)")
            }
        }
        return .success(())
    }
}

extension FirebaseMessagingDataSource: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            // Store FCM token for this device
            UserDefaults.standard.set(token, forKey: "fcmToken")
        }
    }
}
