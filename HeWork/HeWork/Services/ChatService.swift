import Foundation
import FirebaseFirestore
import Combine

// MARK: - ChatService

final class ChatService: ObservableObject {
    static let shared = ChatService()

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    // MARK: - Create Chat

    func createChat(with userId: String) async throws -> String {
        let currentUserId = AuthService.shared.currentUserId
        let chatRef = db.collection("chats").document()

        let chat = Chat(
            id: chatRef.documentID,
            participants: [currentUserId, userId].sorted(),
            lastMessage: nil,
            unreadCount: 0,
            updatedAt: Date(),
            isGroup: false,
            groupName: nil,
            groupAvatarURL: nil
        )

        let data = try Firestore.Encoder().encode(chat)
        try await chatRef.setData(data)
        return chatRef.documentID
    }

    // MARK: - Send Message

    func sendMessage(chatId: String, text: String) async throws {
        let currentUserId = AuthService.shared.currentUserId
        let messageRef = db.collection("chats").document(chatId)
            .collection("messages").document()

        let message = Message(
            id: messageRef.documentID,
            chatId: chatId,
            senderId: currentUserId,
            text: text,
            timestamp: Date(),
            isRead: false,
            messageType: .text
        )

        let messageData = try Firestore.Encoder().encode(message)
        try await messageRef.setData(messageData)

        // Update chat's last message
        let updateData: [String: Any] = [
            "lastMessage": [
                "id": message.id,
                "text": message.text,
                "senderId": message.senderId,
                "timestamp": message.timestamp
            ],
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("chats").document(chatId).updateData(updateData)

        // Send push notification via backend
        sendPushNotification(chatId: chatId, text: text)
    }

    // MARK: - Listen to Messages

    func listenToMessages(chatId: String) -> AnyPublisher<[Message], Error> {
        let subject = PassthroughSubject<[Message], Error>()

        let listener = db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let messages = documents.compactMap { doc -> Message? in
                    do {
                        return try doc.data(as: Message.self)
                    } catch {
                        return nil
                    }
                }

                subject.send(messages)
            }

        self.listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }

    // MARK: - Listen to Chats

    func listenToChats() -> AnyPublisher<[Chat], Error> {
        let subject = PassthroughSubject<[Chat], Error>()
        let currentUserId = AuthService.shared.currentUserId

        let listener = db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let chats = documents.compactMap { doc -> Chat? in
                    do {
                        return try doc.data(as: Chat.self)
                    } catch {
                        return nil
                    }
                }

                subject.send(chats)
            }

        self.listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }

    // MARK: - Mark as Read

    func markAsRead(chatId: String) async throws {
        let currentUserId = AuthService.shared.currentUserId

        let snapshot = try await db.collection("chats").document(chatId)
            .collection("messages")
            .whereField("senderId", isNotEqualTo: currentUserId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()

        for doc in snapshot.documents {
            try await doc.reference.updateData(["isRead": true])
        }

        try await db.collection("chats").document(chatId).updateData([
            "unreadCount": 0
        ])
    }

    // MARK: - Push Notification

    private func sendPushNotification(chatId: String, text: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/notifications/send") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "chatId": chatId,
            "senderId": AuthService.shared.currentUserId,
            "text": text
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request).resume()
    }

    // MARK: - Stop Listening

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}
