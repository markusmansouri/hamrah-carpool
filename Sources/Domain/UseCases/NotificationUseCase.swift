import Foundation

public protocol NotificationUseCase {
    func sendPickupReminder(booking: Booking) async -> Result<Void, NotificationError>
    func sendDelayAlert(booking: Booking, delayMinutes: Int) async -> Result<Void, NotificationError>
    func sendRideStartedNotification(booking: Booking) async -> Result<Void, NotificationError>
    func sendRideCompletedNotification(booking: Booking) async -> Result<Void, NotificationError>
}

public final class DefaultNotificationUseCase: NotificationUseCase {
    public func sendPickupReminder(booking: Booking) async -> Result<Void, NotificationError> {
        let message = "Your ride will arrive in 5 minutes"
        return .success(())
    }
    
    public func sendDelayAlert(booking: Booking, delayMinutes: Int) async -> Result<Void, NotificationError> {
        let message = "Your driver is running \(delayMinutes) minutes late"
        return .success(())
    }
    
    public func sendRideStartedNotification(booking: Booking) async -> Result<Void, NotificationError> {
        let message = "Your ride has started"
        return .success(())
    }
    
    public func sendRideCompletedNotification(booking: Booking) async -> Result<Void, NotificationError> {
        let message = "Your ride is complete. Total cost: \(booking.totalCost)"
        return .success(())
    }
}

public enum NotificationError: LocalizedError {
    case sendFailed
    case invalidToken
    case networkError
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .sendFailed: return "Failed to send notification"
        case .invalidToken: return "Invalid device token"
        case .networkError: return "Network error occurred"
        case .unknown(let message): return message
        }
    }
}
