import Foundation
import SwiftUI

final class ThemeManager: ObservableObject {
    @AppStorage("messageGradientStart") var messageGradientStart: String = AppTheme.default.messageGradientStart
    @AppStorage("messageGradientEnd") var messageGradientEnd: String = AppTheme.default.messageGradientEnd
    @AppStorage("accentColor") var accentColorHex: String = AppTheme.default.accentColor
    @AppStorage("isDarkMode") var isDarkMode: Bool = AppTheme.default.isDarkMode

    var messageGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: messageGradientStart), Color(hex: messageGradientEnd)], startPoint: .leading, endPoint: .trailing)
    }

    var accentColor: Color { Color(hex: accentColorHex) }

    func updateMessageGradient(start: String, end: String) {
        messageGradientStart = start; messageGradientEnd = end
    }
    func updateAccentColor(_ hex: String) { accentColorHex = hex }
    func resetColors() {
        messageGradientStart = AppTheme.default.messageGradientStart
        messageGradientEnd = AppTheme.default.messageGradientEnd
    }
    func resetAccentColor() { accentColorHex = AppTheme.default.accentColor }
}
