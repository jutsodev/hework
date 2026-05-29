import Foundation
import Combine

final class ChatService: ObservableObject {
    static let shared = ChatService()

    private init() {}

    func sendMessage(chatId: String, text: String) async throws {
        // In production: send to Firestore
        // For now: local storage
    }

    func markAsRead(chatId: String) async throws {
        // Mark messages as read
    }
}
