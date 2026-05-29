import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showNewChat = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Text("Чаты")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { showNewChat = true }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20)).foregroundColor(.appAccent)
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 4)

                    // Search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundColor(.appTextSecondary)
                        TextField("Поиск", text: $chatViewModel.searchText).foregroundColor(.white)
                        if !chatViewModel.searchText.isEmpty {
                            Button(action: { chatViewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.appTextSecondary)
                            }
                        }
                    }
                    .padding(12).background(Color.appCard).cornerRadius(12)
                    .padding(.horizontal, 16).padding(.vertical, 8)

                    if chatViewModel.filteredChats.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 56)).foregroundColor(.appTextSecondary)
                            Text("Нет чатов").font(.title3).foregroundColor(.appTextSecondary)
                            Spacer()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                ForEach(chatViewModel.filteredChats) { chat in
                                    NavigationLink(destination: ChatDetailView(chatId: chat.id)) {
                                        ChatListRow(chat: chat)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ChatListRow: View {
    let chat: Chat
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(colors: [.appPurple, .appPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 52, height: 52)
                .overlay(Text(String((chat.groupName ?? "Г").prefix(1))).font(.system(size: 20, weight: .bold)).foregroundColor(.white))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.groupName ?? "Чат").font(.system(size: 16, weight: .semibold)).foregroundColor(.white).lineLimit(1)
                    Spacer()
                    if let t = chat.lastMessage?.timestamp { Text(t.timeString).font(.system(size: 12)).foregroundColor(.appTextSecondary) }
                }
                HStack {
                    Text(chat.lastMessage?.text ?? "Нет сообщений").font(.system(size: 14)).foregroundColor(.appTextSecondary).lineLimit(1)
                    Spacer()
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)").font(.system(size: 11, weight: .bold, design: .rounded)).foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 2).background(Color.appAccent).clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 84)
    }
}
