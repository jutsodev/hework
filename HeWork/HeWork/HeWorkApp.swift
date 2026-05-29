import SwiftUI

@main
struct HeWorkApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var themeManager = ThemeManager()

    init() {
        // Configure notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(themeManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    Task {
                        _ = await NotificationManager.shared.requestAuthorization()
                    }
                }
        }
    }
}
