import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthFlowView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(ChatViewModel())
        .environmentObject(NotificationManager())
        .environmentObject(ThemeManager())
}
