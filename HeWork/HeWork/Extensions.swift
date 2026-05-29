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

    static let appBackground = Color(hex: "0D0D0D")
    static let appCard = Color(hex: "1A1A1A")
    static let appCardLight = Color(hex: "252525")
    static let appTextPrimary = Color.white
    static let appTextSecondary = Color(hex: "999999")
    static let appAccent = Color(hex: "007AFF")
    static let appPurple = Color(hex: "9C27B0")
    static let appPink = Color(hex: "E91E63")
    static let appRed = Color(hex: "FF3B30")
    static let appGreen = Color(hex: "34C759")
    static let appMessageOutgoing = Color(hex: "1C1C1E")
    static let appMessageIncoming = Color(hex: "6C3480")
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
