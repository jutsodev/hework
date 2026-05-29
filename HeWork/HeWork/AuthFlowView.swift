import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if authViewModel.codeSent {
                VerificationCodeView()
            } else {
                EmailEntryView()
            }
        }
    }
}

struct EmailEntryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
                Text("HeWork")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Мессенджер нового поколения")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Электронная почта")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .padding(.leading, 4)
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white)
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
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(isEmailFocused ? Color.white : Color.appBorder, lineWidth: 1))
                }

                if let error = authViewModel.errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.white)
                        Text(error).font(.caption).foregroundColor(.white.opacity(0.7))
                    }.padding(.leading, 4)
                }

                Button(action: { authViewModel.sendVerificationCode() }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("Получить код").fontWeight(.semibold).foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(14)
                }
                .disabled(authViewModel.isLoading || authViewModel.email.isEmpty)
                .opacity(authViewModel.email.isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 8) {
                Text("Нажимая кнопку, вы соглашаетесь с").font(.caption2).foregroundColor(.appTextSecondary)
                HStack(spacing: 4) {
                    Button("Условиями использования") {}.font(.caption2).foregroundColor(.white.opacity(0.6))
                    Text("и").font(.caption2).foregroundColor(.appTextSecondary)
                    Button("Политикой конфиденциальности") {}.font(.caption2).foregroundColor(.white.opacity(0.6))
                }
            }.padding(.bottom, 32)
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isEmailFocused = true } }
    }
}

struct VerificationCodeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var isCodeFocused: Bool
    @State private var codeDigits: [String] = Array(repeating: "", count: 6)

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                Text("Подтверждение")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Мы отправили код на\n\(authViewModel.email)")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        TextField("", text: $codeDigits[index])
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 56)
                            .background(Color.appCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(focusedIndex == index ? Color.white : Color.appBorder, lineWidth: 1.5))
                            .focused($isCodeFocused)
                            .onChange(of: codeDigits[index]) { _, newValue in
                                if newValue.count > 1 { codeDigits[index] = String(newValue.last ?? Character("")) }
                            }
                    }
                }

                if let error = authViewModel.errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.white)
                        Text(error).font(.caption).foregroundColor(.white.opacity(0.7))
                    }
                }

                Button(action: {
                    authViewModel.verificationCode = codeDigits.joined()
                    authViewModel.verifyCode()
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("Подтвердить").fontWeight(.semibold).foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(14)
                }
                .disabled(authViewModel.isLoading || codeDigits.joined().count < 6)
                .opacity(codeDigits.joined().count < 6 ? 0.5 : 1.0)
            }
            .padding(.horizontal, 24)

            VStack(spacing: 8) {
                if authViewModel.resendCooldown > 0 {
                    Text("Повторная отправка через \(authViewModel.resendCooldown) сек")
                        .font(.caption).foregroundColor(.appTextSecondary)
                } else {
                    Button(action: { authViewModel.sendVerificationCode() }) {
                        Text("Отправить код повторно").font(.caption).foregroundColor(.white.opacity(0.6))
                    }
                }
                Button(action: { withAnimation { authViewModel.codeSent = false; authViewModel.errorMessage = nil } }) {
                    Text("Изменить почту").font(.caption).foregroundColor(.appTextSecondary)
                }
            }
            Spacer()
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isCodeFocused = true } }
    }

    private var focusedIndex: Int {
        for i in 0..<6 { if codeDigits[i].isEmpty { return i } }
        return 5
    }
}
