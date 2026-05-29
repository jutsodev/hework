import SwiftUI

struct ChatDetailView: View {
    let chatId: String
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var messageText = ""

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 4) {
                            ForEach(chatViewModel.messages) { message in
                                MessageBubble(message: message).id(message.id)
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 8)
                    }
                    .onChange(of: chatViewModel.messages.count) { _, _ in
                        if let last = chatViewModel.messages.last {
                            withAnimation(.easeOut) { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                HStack(alignment: .bottom, spacing: 8) {
                    Button(action: {}) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 28)).foregroundColor(.appTextSecondary)
                    }
                    TextField("Сообщение...", text: $messageText, axis: .vertical)
                        .font(.system(size: 15)).foregroundColor(.white).lineLimit(1...5)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color.appCard).cornerRadius(20)
                        .overlay(Capsule().stroke(Color.appBorder, lineWidth: 0.5))
                    Button(action: {
                        if !messageText.isEmpty { chatViewModel.sendMessage(text: messageText); messageText = "" }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? .appTextSecondary : .white)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color.appBackground.opacity(0.95))
            }
        }
        .navigationTitle("Алексей Лебедев")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .onAppear { chatViewModel.loadMessages(chatId: chatId) }
    }
}

struct MessageBubble: View {
    let message: Message
    @EnvironmentObject var themeManager: ThemeManager
    private var isOutgoing: Bool { message.senderId == AuthService.shared.currentUserId }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isOutgoing { Spacer(minLength: 60) }
            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(isOutgoing ? .appMessageOutgoingText : .appMessageIncomingText)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(
                        Group {
                            if isOutgoing {
                                RoundedRectangle(cornerRadius: 18).fill(Color.appMessageOutgoing)
                            } else {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.appMessageIncoming)
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.appBorder, lineWidth: 0.5))
                            }
                        }
                    )
                    .contextMenu {
                        Button(action: { UIPasteboard.general.string = message.text }) {
                            Label("Копировать", systemImage: "doc.on.doc")
                        }
                    }
                HStack(spacing: 4) {
                    Text(message.timestamp.timeString).font(.system(size: 11)).foregroundColor(.appTextSecondary)
                    if isOutgoing {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 12)).foregroundColor(message.isRead ? .white : .appTextSecondary)
                    }
                }.padding(.horizontal, 4)
            }
            if !isOutgoing { Spacer(minLength: 60) }
        }.padding(.vertical, 2)
    }
}
