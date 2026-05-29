import Foundation
import Combine

// MARK: - AuthViewModel

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var email = ""
    @Published var verificationCode = ""
    @Published var errorMessage: String?
    @Published var codeSent = false
    @Published var resendCooldown = 0
    @Published var currentUser: User?

    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    private var cooldownTimer: Timer?

    init() {
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)

        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }

    // MARK: - Send Code

    func sendVerificationCode() {
        guard email.isValidEmail else {
            errorMessage = "Введите корректную электронную почту"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let _ = try await authService.sendVerificationCode(to: email)
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

    // MARK: - Verify Code

    func verifyCode() {
        guard verificationCode.count == 6 else {
            errorMessage = "Введите 6-значный код"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let success = try await authService.verifyCode(email: email, code: verificationCode)
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

    // MARK: - Cooldown Timer

    private func startCooldown() {
        resendCooldown = 60
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.resendCooldown -= 1
            if self.resendCooldown <= 0 {
                self.cooldownTimer?.invalidate()
                self.cooldownTimer = nil
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        authService.signOut()
        codeSent = false
        email = ""
        verificationCode = ""
        errorMessage = nil
    }

    deinit {
        cooldownTimer?.invalidate()
    }
}
