import Foundation
import Combine

@MainActor
public final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let messageRepository: MessageRepository
    private var messageTask: Task<Void, Never>?
    private let encryptionService: EncryptionService
    
    public init(
        messageRepository: MessageRepository,
        encryptionService: EncryptionService
    ) {
        self.messageRepository = messageRepository
        self.encryptionService = encryptionService
    }
    
    func loadConversation(senderId: String, recipientId: String) async {
        isLoading = true
        errorMessage = nil
        
        let result = await messageRepository.getConversation(senderId: senderId, recipientId: recipientId)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let messages):
                self.messages = messages
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func sendMessage(senderId: String, recipientId: String, tripId: String) async {
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let encryptResult = encryptionService.encrypt(newMessage)
        guard case .success(let encryptedContent) = encryptResult else {
            errorMessage = "Failed to encrypt message"
            showError = true
            return
        }
        
        let message = Message(
            id: UUID().uuidString,
            senderId: senderId,
            recipientId: recipientId,
            tripId: tripId,
            type: .text,
            content: encryptedContent,
            isEncrypted: true
        )
        
        let result = await messageRepository.sendMessage(message)
        
        await MainActor.run {
            switch result {
            case .success(let sentMessage):
                self.messages.append(sentMessage)
                self.newMessage = ""
            case .failure(let error):
                self.errorMessage = error.errorDescription
                self.showError = true
            }
        }
    }
    
    func subscribeToMessages(userId: String) {
        messageTask = Task {
            let stream = messageRepository.subscribeToMessages(userId: userId)
            
            for await message in stream {
                await MainActor.run {
                    if !self.messages.contains(where: { $0.id == message.id }) {
                        self.messages.append(message)
                    }
                }
            }
        }
    }
    
    func unsubscribeFromMessages() {
        messageTask?.cancel()
    }
}
