import SwiftUI

// MARK: - Contacts View

struct ContactsView: View {
    @State private var searchText = ""
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search
                    SearchBar(text: $searchText)
                        .padding(16)

                    // Contacts List
                    List {
                        Section(header: Text("Онлайн").foregroundColor(.appTextSecondary)) {
                            ContactRow(name: "Алексей Лебедев", handle: "@alexey", isOnline: true)
                            ContactRow(name: "Мария Иванова", handle: "@maria", isOnline: true)
                        }

                        Section(header: Text("Офлайн").foregroundColor(.appTextSecondary)) {
                            ContactRow(name: "Дмитрий Козлов", handle: "@dmitry", isOnline: false)
                            ContactRow(name: "Елена Петрова", handle: "@elena", isOnline: false)
                            ContactRow(name: "Максим Сидоров", handle: "@maxim", isOnline: false)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Контакты")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
        }
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let name: String
    let handle: String
    let isOnline: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.appCardLight)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    )

                if isOnline {
                    Circle()
                        .fill(Color.appGreen)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.appBackground, lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text(handle)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContactsView()
        .environmentObject(ChatViewModel())
}
