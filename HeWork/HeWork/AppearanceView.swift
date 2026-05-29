import SwiftUI

struct AppearanceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("СТИЛЬ СООБЩЕНИЙ").font(.system(size: 12, weight: .semibold)).foregroundColor(.appTextSecondary)

                            HStack {
                                Text("Начало градиента").foregroundColor(.white)
                                Spacer()
                                Circle().fill(Color(hex: themeManager.messageGradientStart)).frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }.padding().background(Color.appCard).cornerRadius(12)

                            HStack {
                                Text("Конец градиента").foregroundColor(.white)
                                Spacer()
                                Circle().fill(Color(hex: themeManager.messageGradientEnd)).frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }.padding().background(Color.appCard).cornerRadius(12)

                            HStack {
                                Spacer()
                                Text("Привет!").font(.system(size: 15)).foregroundColor(.black)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(themeManager.messageGradient).cornerRadius(18)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ColorPreset(start: "#FFFFFF", end: "#CCCCCC", name: "Белый") { themeManager.updateMessageGradient(start: "#FFFFFF", end: "#CCCCCC") }
                                    ColorPreset(start: "#AAAAAA", end: "#666666", name: "Серый") { themeManager.updateMessageGradient(start: "#AAAAAA", end: "#666666") }
                                    ColorPreset(start: "#555555", end: "#333333", name: "Тёмный") { themeManager.updateMessageGradient(start: "#555555", end: "#333333") }
                                    ColorPreset(start: "#E0E0E0", end: "#999999", name: "Серебро") { themeManager.updateMessageGradient(start: "#E0E0E0", end: "#999999") }
                                }
                            }

                            Button(action: { themeManager.resetColors() }) {
                                HStack { Image(systemName: "arrow.counterclockwise"); Text("Сбросить цвета") }
                                    .foregroundColor(.white.opacity(0.6)).font(.subheadline)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("АКЦЕНТНЫЙ ЦВЕТ").font(.system(size: 12, weight: .semibold)).foregroundColor(.appTextSecondary)
                            HStack {
                                Text("Цвет интерфейса").foregroundColor(.white)
                                Spacer()
                                Circle().fill(themeManager.accentColor).frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }.padding().background(Color.appCard).cornerRadius(12)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    AccentBtn(hex: "#FFFFFF") { themeManager.updateAccentColor("#FFFFFF") }
                                    AccentBtn(hex: "#CCCCCC") { themeManager.updateAccentColor("#CCCCCC") }
                                    AccentBtn(hex: "#999999") { themeManager.updateAccentColor("#999999") }
                                    AccentBtn(hex: "#666666") { themeManager.updateAccentColor("#666666") }
                                }
                            }
                            Button(action: { themeManager.resetAccentColor() }) {
                                HStack { Image(systemName: "arrow.counterclockwise"); Text("Сбросить") }
                                    .foregroundColor(.white.opacity(0.6)).font(.subheadline)
                            }
                        }
                    }.padding(16)
                }
            }
            .navigationTitle("Оформление").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Готово") { dismiss() }.foregroundColor(.white) } }
        }
    }
}

struct ColorPreset: View {
    let start: String, end: String, name: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle().fill(LinearGradient(colors: [Color(hex: start), Color(hex: end)], startPoint: .leading, endPoint: .trailing)).frame(width: 40, height: 40)
                Text(name).font(.caption2).foregroundColor(.appTextSecondary)
            }
        }
    }
}

struct AccentBtn: View {
    let hex: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Circle().fill(Color(hex: hex)).frame(width: 36, height: 36)
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
    }
}
