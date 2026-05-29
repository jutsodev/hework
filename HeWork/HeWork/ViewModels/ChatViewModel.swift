import Foundation
import Combine

// MARK: - ChatViewModel

final class ChatViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var messages: [Message] = []
    @Published var contacts: [Contact] = []
    @Published var currentChatId: String?
    @Published var isLoading = false
    @Published var searchText = ""

    private let chatService = ChatService.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Filtered Chats

    var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chats
        }
        return chats.filter { chat in
            if let lastMsg = chat.lastMessage {
                return lastMsg.text.localizedCaseInsensitiveContains(searchText)
            }
            return false
        }
    }

    // MARK: - Load Chats

    func loadChats() {
        chatService.listenToChats()
            .receive(on: DispatchQueue.main)
            .sink { error in
                print("Error loading chats: \(error)")
            } receiveValue: { [weak self] chats in
                self?.chats = chats
            }
            .store(in: &cancellables)
    }

    // MARK: - Load Messages

    func loadMessages(chatId: String) {
        currentChatId = chatId
        chatService.listenToMessages(chatId: chatId)
            .receive(on: DispatchQueue.main)
            .sink { error in
                print("Error loading messages: \(error)")
            } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &cancellables)

        Task {
            try? await chatService.markAsRead(chatId: chatId)
        }
    }

    // MARK: - Send Message

    func sendMessage(text: String) {
        guard let chatId = currentChatId, !text.isEmpty else { return }

        Task {
            do {
                try await chatService.sendMessage(chatId: chatId, text: text)
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }

    // MARK: - Create Chat

    func createChat(with userId: String) {
        Task {
            do {
                let chatId = try await chatService.createChat(with: userId)
                DispatchQueue.main.async {
                    self.currentChatId = chatId
                }
            } catch {
                print("Error creating chat: \(error)")
            }
        }
    }

    // MARK: - Unread Count

    var totalUnreadCount: Int {
        chats.reduce(0) { $0 + $1.unreadCount }
    }

    // MARK: - Cleanup

    func cleanup() {
        chatService.stopListening()
        cancellables.removeAll()
    }
}
