import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var email = ""
    @Published var verificationCode = ""
    @Published var errorMessage: String?
    @Published var codeSent = false
    @Published var resendCooldown = 0
    @Published var currentUser: User?

    private var cooldownTimer: Timer?

    init() {
        AuthService.shared.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
        AuthService.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }

    func sendVerificationCode() {
        guard email.isValidEmail else {
            errorMessage = "Введите корректную электронную почту"
            return
        }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let _ = try await AuthService.shared.sendVerificationCode(to: email)
                await MainActor.run {
                    self.codeSent = true
                    self.isLoading = false
                    self.startCooldown()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func verifyCode() {
        guard verificationCode.count == 6 else {
            errorMessage = "Введите 6-значный код"
            return
        }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let success = try await AuthService.shared.verifyCode(email: email, code: verificationCode)
                await MainActor.run {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        self.errorMessage = "Неверный код. Попробуйте снова"
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func startCooldown() {
        resendCooldown = 60
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.resendCooldown -= 1
            if self.resendCooldown <= 0 { self.cooldownTimer?.invalidate(); self.cooldownTimer = nil }
        }
    }

    func signOut() {
        AuthService.shared.signOut()
        codeSent = false; email = ""; verificationCode = ""; errorMessage = nil
    }

    deinit { cooldownTimer?.invalidate() }
}
