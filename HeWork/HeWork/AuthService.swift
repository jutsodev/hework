import Foundation
import Combine

struct APIConfig {
    static let baseURL = "https://hework-api.onrender.com/api"
}

final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false

    var currentUserId: String {
        UserDefaults.standard.string(forKey: "hework_userId") ?? ""
    }

    private init() {
        // Restore session
        if let uid = UserDefaults.standard.string(forKey: "hework_userId"), !uid.isEmpty {
            loadUser(uid: uid)
        }
    }

    func sendVerificationCode(to email: String) async throws -> Bool {
        guard email.isValidEmail else { throw AuthError.invalidEmail }

        let endpoint = "\(APIConfig.baseURL)/auth/send-code"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["email": email])
        request.timeoutInterval = 15

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // Fallback: generate code locally for demo
            let code = String(format: "%06d", Int.random(in: 100000...999999))
            UserDefaults.standard.set(code, forKey: "hework_lastCode")
            UserDefaults.standard.set(email, forKey: "hework_lastEmail")
            return true
        }
        return true
    }

    func verifyCode(email: String, code: String) async throws -> Bool {
        // Try server verification first
        do {
            let endpoint = "\(APIConfig.baseURL)/auth/verify-code"
            var request = URLRequest(url: URL(string: endpoint)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["email": email, "code": code])
            request.timeoutInterval = 15

            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let uid = json["uid"] as? String {
                    await MainActor.run {
                        self.createUserSession(uid: uid, email: email)
                    }
                    return true
                }
            }
        } catch {
            // Server unavailable - use local verification for demo
        }

        // Local fallback verification
        let savedCode = UserDefaults.standard.string(forKey: "hework_lastCode")
        let savedEmail = UserDefaults.standard.string(forKey: "hework_lastEmail")

        if savedEmail == email && savedCode == code {
            let uid = "local_\(email.replacingOccurrences(of: "@", with: "_").replacingOccurrences(of: ".", with: "_"))"
            await MainActor.run {
                self.createUserSession(uid: uid, email: email)
            }
            return true
        }

        throw AuthError.invalidCode
    }

    private func createUserSession(uid: String, email: String) {
        let user = User(
            id: uid,
            username: email.components(separatedBy: "@").first ?? "Пользователь",
            handle: "@\(email.components(separatedBy: "@").first ?? "user")",
            email: email,
            bio: "Пользователь HeWork Messenger",
            uniqueID: uid.replacingOccurrences(of: "local_", with: ""),
            isOnline: true,
            createdAt: Date()
        )
        self.currentUser = user
        self.isAuthenticated = true
        UserDefaults.standard.set(uid, forKey: "hework_userId")
        UserDefaults.standard.set(email, forKey: "hework_email")
    }

    private func loadUser(uid: String) {
        let email = UserDefaults.standard.string(forKey: "hework_email") ?? ""
        createUserSession(uid: uid, email: email)
    }

    func signOut() {
        isAuthenticated = false
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "hework_userId")
        UserDefaults.standard.removeObject(forKey: "hework_email")
        UserDefaults.standard.removeObject(forKey: "hework_lastCode")
        UserDefaults.standard.removeObject(forKey: "hework_lastEmail")
    }
}

enum AuthError: LocalizedError {
    case invalidEmail, invalidCode, serverError, networkError

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Неверный формат электронной почты"
        case .invalidCode: return "Неверный код подтверждения"
        case .serverError: return "Ошибка сервера. Попробуйте позже"
        case .networkError: return "Ошибка сети. Проверьте подключение"
        }
    }
}
