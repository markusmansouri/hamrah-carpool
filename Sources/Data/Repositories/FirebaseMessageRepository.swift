import Foundation

public final class FirebaseMessageRepository: MessageRepository {
    private let firestoreDataSource: FirestoreDataSource
    private let realtimeDatabaseDataSource: RealtimeDatabaseDataSource
    
    public init(
        firestoreDataSource: FirestoreDataSource,
        realtimeDatabaseDataSource: RealtimeDatabaseDataSource
    ) {
        self.firestoreDataSource = firestoreDataSource
        self.realtimeDatabaseDataSource = realtimeDatabaseDataSource
    }
    
    public func sendMessage(_ message: Message) async -> Result<Message, MessageError> {
        let result = await firestoreDataSource.setDocument(
            message,
            at: "messages/\(message.id)"
        )
        return result.map { message }.mapError { _ in .sendFailed }
    }
    
    public func getMessage(messageId: String) async -> Result<Message, MessageError> {
        let result: Result<Message, DataError> = await firestoreDataSource.getDocument(
            "messages/\(messageId)",
            as: Message.self
        )
        return result.mapError { _ in .messageNotFound }
    }
    
    public func getConversation(senderId: String, recipientId: String) async -> Result<[Message], MessageError> {
        // Query all messages between sender and recipient
        let result: Result<[Message], DataError> = await firestoreDataSource.queryDocuments(
            "messages",
            whereField: "senderId",
            isEqualTo: senderId,
            as: Message.self
        )
        return result.mapError { _ in .fetchFailed }
    }
    
    public func markMessageAsRead(messageId: String) async -> Result<Void, MessageError> {
        let data: [String: Any] = ["isRead": true]
        let result = await firestoreDataSource.updateDocument(
            data,
            at: "messages/\(messageId)"
        )
        return result.mapError { _ in .fetchFailed }
    }
    
    public func subscribeToMessages(userId: String) -> AsyncStream<Message> {
        return AsyncStream { continuation in
            // Listen to real-time updates for user messages
            let stream = realtimeDatabaseDataSource.observeData(at: "messages/\(userId)")
            
            Task {
                for await _ in stream {
                    // Fetch messages for this user
                    // This is a placeholder - real implementation would parse the stream data
                }
            }
        }
    }
}
