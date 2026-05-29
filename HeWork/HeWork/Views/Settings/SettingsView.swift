import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showAppearance = false
    @State private var showProfile = false
    @State private var showQR = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Profile Card
                        Button(action: { showProfile = true }) {
                            ProfileCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        // Appearance Section
                        SettingsSection(header: "ВНЕШНИЙ ВИД") {
                            SettingsRow(icon: "paintbrush.fill", iconColor: .appPurple, title: "Оформление") {
                                showAppearance = true
                            }
                            SettingsToggleRow(icon: "moon.fill", iconColor: .appAccent, title: "Тёмная тема", isOn: $themeManager.isDarkMode)
                        }

                        // System Section
                        SettingsSection(header: "СИСТЕМА") {
                            SettingsToggleRow(icon: "iphone.radiowaves.left.and.right", iconColor: .appGreen, title: "Вибрация", isOn: .constant(true))
                            SettingsRow(icon: "bell.fill", iconColor: .appRed, title: "Уведомления") {
                                // Open notification settings
                            }
                        }

                        // Security Section
                        SettingsSection(header: "БЕЗОПАСНОСТЬ") {
                            SettingsRow(icon: "key.fill", iconColor: .orange, title: "Кодовые слова") {}
                            SettingsRow(icon: "lock.fill", iconColor: .appAccent, title: "Сменить пароль") {}
                        }

                        // About Section
                        SettingsSection(header: "О ПРИЛОЖЕНИИ") {
                            SettingsRow(icon: "info.circle.fill", iconColor: .appAccent, title: "О HeWork") {}
                            SettingsRow(icon: "antenna.radiowaves.left.and.right", iconColor: .appGreen, title: "Протокол Bluetooth Mesh") {}
                        }

                        // Sign Out
                        Button(action: {
                            authViewModel.signOut()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square.fill")
                                    .foregroundColor(.appRed)
                                Text("Выйти")
                                    .foregroundColor(.appRed)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.appCard)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .sheet(isPresented: $showAppearance) {
                AppearanceView()
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showQR) {
                QRCodeView()
            }
        }
    }
}

// MARK: - Profile Card

struct ProfileCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.appPurple, .appPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String((authViewModel.currentUser?.username ?? "Х").prefix(1)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(authViewModel.currentUser?.username ?? "Пользователь")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(authViewModel.currentUser?.handle ?? "@username")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.appTextSecondary)
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let header: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(header)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appTextSecondary)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.appCard)
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                    .background(iconColor.opacity(0.15))
                    .cornerRadius(7)

                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.15))
                .cornerRadius(7)

            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16))

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.appAccent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager())
}
