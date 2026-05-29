import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var messages: [Message] = []
    @Published var currentChatId: String?
    @Published var isLoading = false
    @Published var searchText = ""

    // Demo data
    static let demoChats: [Chat] = {
        let now = Date()
        return [
            Chat(id: "1", participants: ["me", "alexey"], lastMessage: Message(id: "m1", chatId: "1", senderId: "alexey", text: "Привет! Как дела?", timestamp: now.addingTimeInterval(-300), isRead: false, messageType: .text), unreadCount: 3, updatedAt: now, isGroup: false, groupName: "Алексей Лебедев"),
            Chat(id: "2", participants: ["me", "maria"], lastMessage: Message(id: "m2", chatId: "2", senderId: "me", text: "Отлично, договорились!", timestamp: now.addingTimeInterval(-3600), isRead: true, messageType: .text), unreadCount: 0, updatedAt: now.addingTimeInterval(-3600), isGroup: false, groupName: "Мария Иванова"),
            Chat(id: "3", participants: ["me", "dmitry"], lastMessage: Message(id: "m3", chatId: "3", senderId: "dmitry", text: "Это мессенджер без интернета", timestamp: now.addingTimeInterval(-7200), isRead: true, messageType: .text), unreadCount: 1, updatedAt: now.addingTimeInterval(-7200), isGroup: false, groupName: "Дмитрий Козлов"),
            Chat(id: "4", participants: ["me", "elena"], lastMessage: Message(id: "m4", chatId: "4", senderId: "elena", text: "Серьёзно? Как это возможно?", timestamp: now.addingTimeInterval(-86400), isRead: true, messageType: .text), unreadCount: 0, updatedAt: now.addingTimeInterval(-86400), isGroup: false, groupName: "Елена Петрова"),
        ]
    }()

    static let demoMessages: [Message] = {
        let now = Date()
        let uid = AuthService.shared.currentUserId
        return [
            Message(id: "d1", chatId: "1", senderId: "alexey", text: "Привет!", timestamp: now.addingTimeInterval(-600), isRead: true, messageType: .text),
            Message(id: "d2", chatId: "1", senderId: uid, text: "Привет! Как дела?", timestamp: now.addingTimeInterval(-500), isRead: true, messageType: .text),
            Message(id: "d3", chatId: "1", senderId: "alexey", text: "Это мессенджер, который работает без интернета — только Bluetooth", timestamp: now.addingTimeInterval(-400), isRead: true, messageType: .text),
            Message(id: "d4", chatId: "1", senderId: uid, text: "Серьёзно? Как это вообще возможно?", timestamp: now.addingTimeInterval(-300), isRead: true, messageType: .text),
            Message(id: "d5", chatId: "1", senderId: "alexey", text: "Представь: Макс пишет Тому через 5 человек между ними", timestamp: now.addingTimeInterval(-200), isRead: false, messageType: .text),
            Message(id: "d6", chatId: "1", senderId: uid, text: "Круто! А шифрование есть?", timestamp: now.addingTimeInterval(-100), isRead: true, messageType: .text),
            Message(id: "d7", chatId: "1", senderId: "alexey", text: "Да, Curve25519 + AES-GCM, end-to-end", timestamp: now, isRead: false, messageType: .text),
        ]
    }()

    var filteredChats: [Chat] {
        if searchText.isEmpty { return chats }
        return chats.filter { chat in
            chat.groupName?.localizedCaseInsensitiveContains(searchText) ?? false ||
            (chat.lastMessage?.text.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    func loadChats() {
        chats = ChatViewModel.demoChats
    }

    func loadMessages(chatId: String) {
        currentChatId = chatId
        messages = ChatViewModel.demoMessages
    }

    func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        let msg = Message(
            id: UUID().uuidString,
            chatId: currentChatId ?? "",
            senderId: AuthService.shared.currentUserId,
            text: text,
            timestamp: Date(),
            isRead: false,
            messageType: .text
        )
        messages.append(msg)

        // Simulate reply after 1-3 seconds
        let replies = ["Понял!", "Хорошо 👍", "Отлично!", "Интересно...", "Ок!", "🔥", "Спасибо!"]
        let delay = Double.random(in: 1.0...3.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let reply = Message(
                id: UUID().uuidString,
                chatId: self.currentChatId ?? "",
                senderId: "alexey",
                text: replies.randomElement() ?? "Ок!",
                timestamp: Date(),
                isRead: false,
                messageType: .text
            )
            self.messages.append(reply)
            NotificationManager.shared.scheduleLocalNotification(
                title: "Алексей Лебедев",
                body: reply.text,
                userInfo: ["chatId": self.currentChatId ?? ""]
            )
        }
    }

    var totalUnreadCount: Int { chats.reduce(0) { $0 + $1.unreadCount } }
}
