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
                            Text("ЦВЕТ СООБЩЕНИЙ").font(.system(size: 12, weight: .semibold)).foregroundColor(.appTextSecondary)
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
                                Text("Привет!").font(.system(size: 15)).foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(themeManager.messageGradient).cornerRadius(18)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ColorPreset(start: "#9C27B0", end: "#E91E63", name: "Фиолет") { themeManager.updateMessageGradient(start: "#9C27B0", end: "#E91E63") }
                                    ColorPreset(start: "#007AFF", end: "#5AC8FA", name: "Океан") { themeManager.updateMessageGradient(start: "#007AFF", end: "#5AC8FA") }
                                    ColorPreset(start: "#34C759", end: "#30D158", name: "Мята") { themeManager.updateMessageGradient(start: "#34C759", end: "#30D158") }
                                    ColorPreset(start: "#FF9500", end: "#FF3B30", name: "Закат") { themeManager.updateMessageGradient(start: "#FF9500", end: "#FF3B30") }
                                    ColorPreset(start: "#5856D6", end: "#AF52DE", name: "Космос") { themeManager.updateMessageGradient(start: "#5856D6", end: "#AF52DE") }
                                }
                            }
                            Button(action: { themeManager.resetColors() }) {
                                HStack { Image(systemName: "arrow.counterclockwise"); Text("Сбросить цвета") }
                                    .foregroundColor(.appRed).font(.subheadline)
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
                                    AccentBtn(hex: "#007AFF") { themeManager.updateAccentColor("#007AFF") }
                                    AccentBtn(hex: "#5856D6") { themeManager.updateAccentColor("#5856D6") }
                                    AccentBtn(hex: "#34C759") { themeManager.updateAccentColor("#34C759") }
                                    AccentBtn(hex: "#FF9500") { themeManager.updateAccentColor("#FF9500") }
                                    AccentBtn(hex: "#FF3B30") { themeManager.updateAccentColor("#FF3B30") }
                                }
                            }
                            Button(action: { themeManager.resetAccentColor() }) {
                                HStack { Image(systemName: "arrow.counterclockwise"); Text("Сбросить") }
                                    .foregroundColor(.appRed).font(.subheadline)
                            }
                        }
                    }.padding(16)
                }
            }
            .navigationTitle("Оформление").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Готово") { dismiss() }.foregroundColor(.appAccent) } }
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
