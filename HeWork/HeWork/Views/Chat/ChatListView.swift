import SwiftUI

// MARK: - Chat List View

struct ChatListView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showNewChat = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    ChatListHeader()

                    // Search Bar
                    SearchBar(text: $chatViewModel.searchText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                    // Chat List
                    if chatViewModel.filteredChats.isEmpty {
                        EmptyChatsView()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                ForEach(chatViewModel.filteredChats) { chat in
                                    ChatListRow(chat: chat)
                                        .onTapGesture {
                                            chatViewModel.loadMessages(chatId: chat.id)
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewChat) {
                NewChatView()
            }
        }
    }
}

// MARK: - Chat List Header

struct ChatListHeader: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showNewChat = false

    var body: some View {
        HStack {
            Text("Чаты")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Button(action: {
                showNewChat = true
            }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20))
                    .foregroundColor(.appAccent)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }
}

// MARK: - Search Bar

struct SearchBar: BindingProvider {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appTextSecondary)

            TextField("Поиск", text: $text)
                .foregroundColor(.white)
                .focused($isFocused)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.appCard)
        .cornerRadius(12)
    }
}

// MARK: - Chat List Row

struct ChatListRow: View {
    let chat: Chat
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.appPurple, .appPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .overlay(
                    Text(String(chat.chatName.prefix(1)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                )

            // Chat Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.chatName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Spacer()

                    if let lastMsg = chat.lastMessage {
                        Text(lastMsg.timestamp.timeString)
                            .font(.system(size: 12))
                            .foregroundColor(.appTextSecondary)
                    }
                }

                HStack {
                    if let lastMsg = chat.lastMessage {
                        Text(lastMsg.text)
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                            .lineLimit(1)
                    } else {
                        Text("Нет сообщений")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                    }

                    Spacer()

                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.appAccent)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)

        Divider()
            .background(Color.white.opacity(0.06))
            .padding(.leading, 84)
    }
}

// MARK: - Empty Chats View

struct EmptyChatsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 56))
                .foregroundColor(.appTextSecondary)

            Text("Нет чатов")
                .font(.title3)
                .foregroundColor(.appTextSecondary)

            Text("Начните новый разговор")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)

            Spacer()
        }
    }
}

// MARK: - New Chat View

struct NewChatView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var searchQuery = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    SearchBar(text: $searchQuery)
                        .padding(16)

                    Text("Контакты")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                    List {
                        ForEach(0..<5) { _ in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.appCardLight)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.appTextSecondary)
                                    )

                                VStack(alignment: .leading) {
                                    Text("Пользователь")
                                        .foregroundColor(.white)
                                    Text("@username")
                                        .font(.caption)
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                            .padding(.vertical, 4)
                            .onTapGesture {
                                chatViewModel.createChat(with: "user_id")
                                dismiss()
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Новый чат")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.appAccent)
                }
            }
        }
    }
}

#Preview {
    ChatListView()
        .environmentObject(ChatViewModel())
        .environmentObject(ThemeManager())
}
