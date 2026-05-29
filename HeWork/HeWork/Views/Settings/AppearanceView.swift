import SwiftUI

// MARK: - Appearance View

struct AppearanceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var gradientStart: String = ""
    @State private var gradientEnd: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Message Color Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ЦВЕТ СООБЩЕНИЙ")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.appTextSecondary)

                            // Gradient Start
                            HStack {
                                Text("Начало градиента")
                                    .foregroundColor(.white)
                                Spacer()
                                Circle()
                                    .fill(Color(hex: themeManager.messageGradientStart))
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }
                            .padding()
                            .background(Color.appCard)
                            .cornerRadius(12)

                            // Gradient End
                            HStack {
                                Text("Конец градиента")
                                    .foregroundColor(.white)
                                Spacer()
                                Circle()
                                    .fill(Color(hex: themeManager.messageGradientEnd))
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }
                            .padding()
                            .background(Color.appCard)
                            .cornerRadius(12)

                            // Preview
                            HStack {
                                Spacer()
                                Text("Привет!")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(themeManager.messageGradient)
                                    .cornerRadius(18)
                            }

                            // Color Presets
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Пресеты")
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ColorPresetButton(
                                            start: "#9C27B0", end: "#E91E63",
                                            name: "Фиолет"
                                        ) {
                                            themeManager.updateMessageGradient(start: "#9C27B0", end: "#E91E63")
                                        }
                                        ColorPresetButton(
                                            start: "#007AFF", end: "#5AC8FA",
                                            name: "Океан"
                                        ) {
                                            themeManager.updateMessageGradient(start: "#007AFF", end: "#5AC8FA")
                                        }
                                        ColorPresetButton(
                                            start: "#34C759", end: "#30D158",
                                            name: "Мята"
                                        ) {
                                            themeManager.updateMessageGradient(start: "#34C759", end: "#30D158")
                                        }
                                        ColorPresetButton(
                                            start: "#FF9500", end: "#FF3B30",
                                            name: "Закат"
                                        ) {
                                            themeManager.updateMessageGradient(start: "#FF9500", end: "#FF3B30")
                                        }
                                        ColorPresetButton(
                                            start: "#5856D6", end: "#AF52DE",
                                            name: "Космос"
                                        ) {
                                            themeManager.updateMessageGradient(start: "#5856D6", end: "#AF52DE")
                                        }
                                    }
                                }
                            }

                            // Reset
                            Button(action: {
                                themeManager.resetColors()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Сбросить цвета")
                                }
                                .foregroundColor(.appRed)
                                .font(.subheadline)
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.06))

                        // Accent Color Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("АКЦЕНТНЫЙ ЦВЕТ")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.appTextSecondary)

                            HStack {
                                Text("Цвет интерфейса")
                                    .foregroundColor(.white)
                                Spacer()
                                Circle()
                                    .fill(themeManager.accentColor)
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }
                            .padding()
                            .background(Color.appCard)
                            .cornerRadius(12)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    AccentPresetButton(hex: "#007AFF") { themeManager.updateAccentColor("#007AFF") }
                                    AccentPresetButton(hex: "#5856D6") { themeManager.updateAccentColor("#5856D6") }
                                    AccentPresetButton(hex: "#34C759") { themeManager.updateAccentColor("#34C759") }
                                    AccentPresetButton(hex: "#FF9500") { themeManager.updateAccentColor("#FF9500") }
                                    AccentPresetButton(hex: "#FF3B30") { themeManager.updateAccentColor("#FF3B30") }
                                    AccentPresetButton(hex: "#AF52DE") { themeManager.updateAccentColor("#AF52DE") }
                                }
                            }

                            Button(action: {
                                themeManager.resetAccentColor()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Сбросить")
                                }
                                .foregroundColor(.appRed)
                                .font(.subheadline)
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.06))

                        // Wallpaper Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ОБОИ ВСЕХ ЧАТОВ")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.appTextSecondary)

                            HStack {
                                Image(systemName: "photo.fill")
                                    .foregroundColor(.appAccent)
                                Text("Установить для всех чатов")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.appTextSecondary)
                            }
                            .padding()
                            .background(Color.appCard)
                            .cornerRadius(12)

                            Button(action: {
                                themeManager.wallpaperName = nil
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Сбросить обои всех чатов")
                                }
                                .foregroundColor(.appRed)
                                .font(.subheadline)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Оформление")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .foregroundColor(.appAccent)
                }
            }
        }
    }
}

// MARK: - Color Preset Button

struct ColorPresetButton: View {
    let start: String
    let end: String
    let name: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: start), Color(hex: end)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Text(name)
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
            }
        }
    }
}

// MARK: - Accent Preset Button

struct AccentPresetButton: View {
    let hex: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: hex))
                .frame(width: 36, height: 36)
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
    }
}

#Preview {
    AppearanceView()
        .environmentObject(ThemeManager())
}
