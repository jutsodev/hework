import SwiftUI

// MARK: - Chat Detail View

struct ChatDetailView: View {
    let chatId: String
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var messageText = ""
    @FocusState private var isMessageFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 4) {
                            ForEach(chatViewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: chatViewModel.messages.count) { _, _ in
                        if let lastMessage = chatViewModel.messages.last {
                            withAnimation(.easeOut) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input Bar
                MessageInputBar(
                    text: $messageText,
                    isFocused: $isMessageFieldFocused,
                    onSend: {
                        chatViewModel.sendMessage(text: messageText)
                        messageText = ""
                    }
                )
            }
        }
        .navigationTitle("Чат")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .onAppear {
            chatViewModel.loadMessages(chatId: chatId)
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message
    @EnvironmentObject var themeManager: ThemeManager

    private var isOutgoing: Bool {
        message.isCurrentUser
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isOutgoing { Spacer(minLength: 60) }

            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 4) {
                // Message bubble
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Group {
                            if isOutgoing {
                                // Outgoing message: gradient
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(themeManager.messageGradient)
                            } else {
                                // Incoming message: dark glass
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.appMessageOutgoing)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                                    )
                            }
                        }
                    )
                    .contextMenu {
                        Button(action: copyMessage) {
                            Label("Копировать", systemImage: "doc.on.doc")
                        }
                        Button(action: {}) {
                            Label("Ответить", systemImage: "arrowshape.turn.up.left")
                        }
                        Button(role: .destructive, action: {}) {
                            Label("Удалить", systemImage: "trash")
                        }
                    }

                // Timestamp
                HStack(spacing: 4) {
                    Text(message.timestamp.timeString)
                        .font(.system(size: 11))
                        .foregroundColor(.appTextSecondary)

                    if isOutgoing {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 12))
                            .foregroundColor(message.isRead ? .appAccent : .appTextSecondary)
                    }
                }
                .padding(.horizontal, 4)
            }

            if !isOutgoing { Spacer(minLength: 60) }
        }
        .padding(.vertical, 2)
    }

    private func copyMessage() {
        UIPasteboard.general.string = message.text
    }
}

// MARK: - Message Input Bar

struct MessageInputBar: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    let onSend: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Attach button
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.appAccent)
            }

            // Text field
            TextField("Сообщение...", text: $text, axis: .vertical)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .lineLimit(1...5)
                .focused($isFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.appCard)
                .cornerRadius(20)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                )

            // Send button
            Button(action: {
                if !text.isEmpty {
                    onSend()
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.isEmpty ? .appTextSecondary : .appAccent)
            }
            .disabled(text.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(Color.appBackground.opacity(0.95))
                .blur(radius: 20)
        )
    }
}

#Preview {
    NavigationStack {
        ChatDetailView(chatId: "test")
            .environmentObject(ChatViewModel())
            .environmentObject(ThemeManager())
    }
}
