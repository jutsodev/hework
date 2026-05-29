import Foundation
import SwiftUI

struct User: Identifiable, Codable, Equatable {
    let id: String
    var username: String
    var handle: String
    var email: String
    var phoneNumber: String?
    var bio: String
    var avatarURL: String?
    var uniqueID: String
    var isOnline: Bool
    var lastSeen: Date?
    var createdAt: Date

    var displayName: String { username.isEmpty ? handle : username }

    static func == (lhs: User, rhs: User) -> Bool { lhs.id == rhs.id }
}

struct Chat: Identifiable, Codable {
    let id: String
    var participants: [String]
    var lastMessage: Message?
    var unreadCount: Int
    var updatedAt: Date
    var isGroup: Bool
    var groupName: String?
    var groupAvatarURL: String?

    var chatName: String { isGroup ? (groupName ?? "Группа") : "" }
}

struct Message: Identifiable, Codable {
    let id: String
    let chatId: String
    let senderId: String
    let text: String
    let timestamp: Date
    var isRead: Bool
    var messageType: MessageType

    enum MessageType: String, Codable { case text, image, file, voice, system }
    var isCurrentUser: Bool { senderId == AuthService.shared.currentUserId }
}

struct Contact: Identifiable, Codable {
    let id: String
    var userId: String
    var displayName: String
    var handle: String
    var avatarURL: String?
    var isOnline: Bool
}

struct AppTheme: Codable {
    var messageGradientStart: String
    var messageGradientEnd: String
    var accentColor: String
    var isDarkMode: Bool
    var wallpaperName: String?

    static let `default` = AppTheme(
        messageGradientStart: "#FFFFFF",
        messageGradientEnd: "#CCCCCC",
        accentColor: "#FFFFFF",
        isDarkMode: true,
        wallpaperName: nil
    )
}

enum AppTab: String, CaseIterable {
    case chats = "Чаты"
    case nearby = "Рядом"
    case contacts = "Контакты"
    case settings = "Настройки"

    var icon: String {
        switch self {
        case .chats: return "bubble.left.and.bubble.right.fill"
        case .nearby: return "location.fill"
        case .contacts: return "person.2.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var sfSymbol: String {
        switch self {
        case .chats: return "bubble.left.and.bubble.right"
        case .nearby: return "location"
        case .contacts: return "person.2"
        case .settings: return "gearshape"
        }
    }
}
