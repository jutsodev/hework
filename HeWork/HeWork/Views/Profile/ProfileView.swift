import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Profile View

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showQR = false
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.appPurple, .appPink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(String((authViewModel.currentUser?.username ?? "Х").prefix(1)))
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                )

                            // Edit overlay
                            Circle()
                                .fill(Color.appAccent.opacity(0.8))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 35, y: 35)
                        }

                        // Name & Handle
                        VStack(spacing: 4) {
                            Text(authViewModel.currentUser?.username ?? "Пользователь")
                                .font(.title2.bold())
                                .foregroundColor(.white)

                            Text(authViewModel.currentUser?.handle ?? "@username")
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)

                            // Online status
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.appGreen)
                                    .frame(width: 8, height: 8)
                                Text("ОНЛАЙН")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.appGreen)
                            }
                            .padding(.top, 4)
                        }

                        // Bio
                        if let bio = authViewModel.currentUser?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        // Quick Actions
                        HStack(spacing: 24) {
                            ProfileActionButton(icon: "person.fill", title: "Мой профиль") {
                                showEditProfile = true
                            }
                            ProfileActionButton(icon: "pencil", title: "Редактировать") {
                                showEditProfile = true
                            }
                            ProfileActionButton(icon: "qrcode", title: "QR код") {
                                showQR = true
                            }
                            ProfileActionButton(icon: "qrcode.viewfinder", title: "Сканер QR") {
                                // Open QR scanner
                            }
                        }
                        .padding(.vertical, 8)

                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.horizontal, 16)

                        // Contact Info
                        VStack(spacing: 0) {
                            if let phone = authViewModel.currentUser?.phoneNumber {
                                ProfileInfoRow(icon: "phone.fill", label: "Телефон", value: phone)
                            }

                            ProfileInfoRow(
                                icon: "envelope.fill",
                                label: "Email",
                                value: authViewModel.currentUser?.email ?? ""
                            )

                            ProfileInfoRow(
                                icon: "number",
                                label: "Уникальный номер",
                                value: authViewModel.currentUser?.uniqueID ?? ""
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Мой профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.appAccent)
                }
            }
            .sheet(isPresented: $showQR) {
                QRCodeView()
            }
        }
    }
}

// MARK: - Profile Action Button

struct ProfileActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.appAccent)
                    .frame(width: 44, height: 44)
                    .background(Color.appAccent.opacity(0.12))
                    .cornerRadius(12)

                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Profile Info Row

struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String

    @State private var showCopied = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.appAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: {
                UIPasteboard.general.string = value
                showCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCopied = false
                }
            }) {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 14))
                    .foregroundColor(.appAccent)
            }
        }
        .padding()
        .background(Color.appCard)
        .cornerRadius(12)
    }
}

// MARK: - QR Code View

struct QRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // QR Code
                    VStack(spacing: 16) {
                        Image(uiImage: generateQRCode(from: authViewModel.currentUser?.uniqueID ?? "hework"))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)

                        VStack(spacing: 4) {
                            Text(authViewModel.currentUser?.username ?? "Пользователь")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            Text(authViewModel.currentUser?.handle ?? "@username")
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                            Text("ID: \(authViewModel.currentUser?.uniqueID?.prefix(12) ?? "")...")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
                    }

                    // Share Button
                    Button(action: {
                        // Share QR code
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Поделиться QR-кодом")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.appPurple, .appPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
            }
            .navigationTitle("Мой QR-код")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.appAccent)
                }
            }
        }
    }

    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "qrcode")!
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
