import SwiftUI

// MARK: - Auth Flow View

struct AuthFlowView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            if authViewModel.codeSent {
                VerificationCodeView()
            } else {
                EmailEntryView()
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - Email Entry View

struct EmailEntryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo
            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.appPurple, .appPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("HeWork")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Мессенджер нового поколения")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }

            // Email Input
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Электронная почта")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .padding(.leading, 4)

                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.appAccent)
                            .font(.body)

                        TextField("example@mail.com", text: $authViewModel.email)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isEmailFocused)
                    }
                    .padding()
                    .background(Color.appCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isEmailFocused ? Color.appAccent : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
                }

                // Error Message
                if let error = authViewModel.errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.appRed)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.appRed)
                    }
                    .padding(.leading, 4)
                }

                // Send Code Button
                Button(action: {
                    authViewModel.sendVerificationCode()
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Получить код")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.appPurple, .appPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(authViewModel.isLoading || authViewModel.email.isEmpty)
                .opacity(authViewModel.email.isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 24)

            Spacer()

            // Footer
            VStack(spacing: 8) {
                Text("Нажимая кнопку, вы соглашаетесь с")
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
                HStack(spacing: 4) {
                    Button("Условиями использования") {}
                        .font(.caption2)
                        .foregroundColor(.appAccent)
                    Text("и")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                    Button("Политикой конфиденциальности") {}
                        .font(.caption2)
                        .foregroundColor(.appAccent)
                }
            }
            .padding(.bottom, 32)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isEmailFocused = true
            }
        }
    }
}

// MARK: - Verification Code View

struct VerificationCodeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var isCodeFocused: Bool
    @State private var codeDigits: [String] = Array(repeating: "", count: 6)

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 48))
                    .foregroundColor(.appAccent)

                Text("Подтверждение")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Мы отправили код на\n\(authViewModel.email)")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Code Input
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        VerificationDigitCell(
                            text: $codeDigits[index],
                            isFocused: focusedIndex == index
                        )
                        .focused($isCodeFocused)
                    }
                }

                // Error Message
                if let error = authViewModel.errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.appRed)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.appRed)
                    }
                }

                // Verify Button
                Button(action: {
                    authViewModel.verificationCode = codeDigits.joined()
                    authViewModel.verifyCode()
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Подтвердить")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.appPurple, .appPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(authViewModel.isLoading || codeDigits.joined().count < 6)
                .opacity(codeDigits.joined().count < 6 ? 0.5 : 1.0)
            }
            .padding(.horizontal, 24)

            // Resend Code
            VStack(spacing: 8) {
                if authViewModel.resendCooldown > 0 {
                    Text("Повторная отправка через \(authViewModel.resendCooldown) сек")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                } else {
                    Button(action: {
                        authViewModel.sendVerificationCode()
                    }) {
                        Text("Отправить код повторно")
                            .font(.caption)
                            .foregroundColor(.appAccent)
                    }
                }

                Button(action: {
                    withAnimation {
                        authViewModel.codeSent = false
                        authViewModel.errorMessage = nil
                    }
                }) {
                    Text("Изменить почту")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isCodeFocused = true
            }
        }
    }

    private var focusedIndex: Int {
        for i in 0..<6 {
            if codeDigits[i].isEmpty { return i }
        }
        return 5
    }
}

// MARK: - Verification Digit Cell

struct VerificationDigitCell: View {
    @Binding var text: String
    let isFocused: Bool

    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .multilineTextAlignment(.center)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 48, height: 56)
            .background(Color.appCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? Color.appAccent : Color.white.opacity(0.1),
                        lineWidth: 1.5
                    )
            )
            .onChange(of: text) { _, newValue in
                if newValue.count > 1 {
                    text = String(newValue.last ?? Character(""))
                }
            }
    }
}

#Preview {
    AuthFlowView()
        .environmentObject(AuthViewModel())
}
