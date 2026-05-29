import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }

    // MARK: - Black & White Palette
    static let appBackground = Color(hex: "000000")
    static let appCard = Color(hex: "1A1A1A")
    static let appCardLight = Color(hex: "2A2A2A")
    static let appTextPrimary = Color.white
    static let appTextSecondary = Color(hex: "888888")
    static let appAccent = Color.white
    static let appAccentDim = Color(hex: "666666")
    static let appRed = Color(hex: "CCCCCC")
    static let appGreen = Color.white
    static let appMessageOutgoing = Color.white
    static let appMessageOutgoingText = Color.black
    static let appMessageIncoming = Color(hex: "1C1C1E")
    static let appMessageIncomingText = Color.white
    static let appDivider = Color.white.opacity(0.08)
    static let appBorder = Color.white.opacity(0.12)
    static let appBadge = Color.white
    static let appBadgeText = Color.black
}

extension Date {
    var timeString: String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: self)
    }
    var relativeString: String {
        let f = RelativeDateTimeFormatter(); f.locale = Locale(identifier: "ru_RU"); f.unitsStyle = .short
        return f.localizedString(for: self, relativeTo: Date())
    }
}

extension String {
    var isValidEmail: Bool {
        let r = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", r).evaluate(with: self)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let p = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(p.cgPath)
    }
}
