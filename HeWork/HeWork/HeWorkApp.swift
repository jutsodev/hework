import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
struct HeWorkApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var themeManager = ThemeManager()

    init() {
        setupFirebase()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(notificationManager)
                .environmentObject(themeManager)
                .preferredColorScheme(.dark)
        }
    }

    private func setupFirebase() {
        FirebaseApp.configure()
    }
}
