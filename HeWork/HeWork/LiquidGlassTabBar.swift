import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .chats
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .chats: ChatListView()
                case .nearby: NearbyView()
                case .contacts: ContactsView()
                case .settings: SettingsView()
                }
            }
            .padding(.bottom, 80)

            LiquidGlassTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear { chatViewModel.loadChats() }
    }
}

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    badgeCount: tab == .chats ? chatViewModel.totalUnreadCount : 0
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .padding(.bottom, 4)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .opacity(0.7)
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(stops: [
                            .init(color: Color.white.opacity(0.1), location: 0.0),
                            .init(color: Color.white.opacity(0.03), location: 0.3),
                            .init(color: Color.white.opacity(0.06), location: 0.7),
                            .init(color: Color.white.opacity(0.12), location: 1.0)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(stops: [
                            .init(color: Color.white.opacity(0.35), location: 0.0),
                            .init(color: Color.white.opacity(0.05), location: 0.4),
                            .init(color: Color.white.opacity(0.15), location: 0.8),
                            .init(color: Color.white.opacity(0.25), location: 1.0)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 0.5
                    )
            }
            .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
            .shadow(color: Color.purple.opacity(0.1), radius: 20, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
    }
}

struct TabBarItem: View {
    let tab: AppTab
    let isSelected: Bool
    let badgeCount: Int
    let action: () -> Void
    @State private var scaleEffect: CGFloat = 1.0

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scaleEffect = 0.9 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scaleEffect = 1.0 }
            }
            action()
        }) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? tab.icon : tab.sfSymbol)
                        .font(.system(size: 22))
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(isSelected ? .appAccent : .appTextSecondary)
                        .scaleEffect(scaleEffect)
                    if badgeCount > 0 {
                        Text(badgeCount > 99 ? "99+" : "\(badgeCount)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Color.appRed).clipShape(Capsule())
                            .offset(x: 10, y: -6)
                    }
                }
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .appAccent : .appTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
