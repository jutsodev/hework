import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Circle().fill(Color.appCardLight)
                            .frame(width: 100, height: 100)
                            .overlay(Text(String((authViewModel.currentUser?.username ?? "Х").prefix(1))).font(.system(size: 40, weight: .bold)).foregroundColor(.white))

                        VStack(spacing: 4) {
                            Text(authViewModel.currentUser?.username ?? "Пользователь").font(.title2.bold()).foregroundColor(.white)
                            Text(authViewModel.currentUser?.handle ?? "@username").font(.subheadline).foregroundColor(.appTextSecondary)
                            HStack(spacing: 6) {
                                Circle().fill(Color.white).frame(width: 8, height: 8)
                                Text("ОНЛАЙН").font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                            }.padding(.top, 4)
                        }

                        if let bio = authViewModel.currentUser?.bio, !bio.isEmpty {
                            Text(bio).font(.subheadline).foregroundColor(.appTextSecondary).multilineTextAlignment(.center).padding(.horizontal, 32)
                        }

                        Divider().background(Color.appDivider).padding(.horizontal, 16)

                        VStack(spacing: 0) {
                            ProfileInfoRow(icon: "envelope.fill", label: "Email", value: authViewModel.currentUser?.email ?? "")
                            ProfileInfoRow(icon: "number", label: "Уникальный номер", value: authViewModel.currentUser?.uniqueID ?? "")
                        }.padding(.horizontal, 16)
                    }.padding(.top, 20)
                }
            }
            .navigationTitle("Мой профиль").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Закрыть") { dismiss() }.foregroundColor(.white) } }
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String, label: String, value: String
    @State private var showCopied = false
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(.white).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(.appTextSecondary)
                Text(value).font(.system(size: 14)).foregroundColor(.white).lineLimit(1)
            }
            Spacer()
            Button(action: { UIPasteboard.general.string = value; showCopied = true; DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showCopied = false } }) {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc").font(.system(size: 14)).foregroundColor(.white.opacity(0.6))
            }
        }
        .padding().background(Color.appCard).cornerRadius(12)
    }
}
