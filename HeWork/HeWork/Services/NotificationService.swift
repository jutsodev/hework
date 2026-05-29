import Foundation
import UserNotifications
import FirebaseMessaging
import UIKit

// MARK: - NotificationManager

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var fcmToken: String?

    private init() {}

    // MARK: - Request Permission

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.isAuthorized = granted
            }

            if granted {
                await UIApplication.shared.registerForRemoteNotifications()
                Messaging.messaging().subscribe(toTopic: "hework_messages")
            }

            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Update FCM Token

    func updateFCMToken() {
        Messaging.messaging().token { [weak self] token, error in
            if let token = token {
                self?.fcmToken = token
                self?.sendTokenToServer(token)
            }
        }
    }

    private func sendTokenToServer(_ token: String) {
        // Send FCM token to backend for push notifications
        guard let url = URL(string: "\(APIConfig.baseURL)/notifications/register-token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "token": token,
            "userId": AuthService.shared.currentUserId,
            "platform": "ios"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request).resume()
    }

    // MARK: - Local Notification

    func scheduleLocalNotification(title: String, body: String, userInfo: [AnyHashable: Any]? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber + 1))
        if let userInfo = userInfo {
            content.userInfo = userInfo
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    // MARK: - Clear Badges

    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

// MARK: - AppDelegate Notification Handling

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        print("Foreground notification: \(userInfo)")
        return [.banner, .sound, .badge]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped: \(userInfo)")

        // Handle deep link from notification
        if let chatId = userInfo["chatId"] as? String {
            NotificationCenter.default.post(
                name: .openChat,
                object: nil,
                userInfo: ["chatId": chatId]
            )
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openChat = Notification.Name("openChat")
}
