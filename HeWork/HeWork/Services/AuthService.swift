import Foundation
import Combine
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth

// MARK: - AuthService

final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false

    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    private init() {
        listenToAuthState()
    }

    // MARK: - Auth State Listener

    private func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.fetchUserProfile(uid: user.uid)
                } else {
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }

    // MARK: - Send Verification Code

    func sendVerificationCode(to email: String) async throws -> Bool {
        guard email.isValidEmail else {
            throw AuthError.invalidEmail
        }

        let endpoint = "\(APIConfig.baseURL)/auth/send-code"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email]
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.serverError
        }

        return true
    }

    // MARK: - Verify Code

    func verifyCode(email: String, code: String) async throws -> Bool {
        let endpoint = "\(APIConfig.baseURL)/auth/verify-code"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "code": code]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.invalidCode
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let customToken = json["customToken"] as? String {
            try await Auth.auth().signIn(withCustomToken: customToken)
            return true
        }

        return false
    }

    // MARK: - Fetch User Profile

    private func fetchUserProfile(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let data = snapshot?.data() {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        self?.currentUser = try JSONDecoder().decode(User.self, from: jsonData)
                        self?.isAuthenticated = true
                    } catch {
                        print("Error decoding user: \(error)")
                    }
                }
            }
        }
    }

    // MARK: - Update Profile

    func updateProfile(username: String, bio: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let updates: [String: Any] = [
            "username": username,
            "bio": bio
        ]

        try await db.collection("users").document(uid).updateData(updates)

        DispatchQueue.main.async {
            self.currentUser?.username = username
            self.currentUser?.bio = bio
        }
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        } catch {
            print("Error signing out: \(error)")
        }
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await db.collection("users").document(user.uid).delete()
        try await user.delete()
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidEmail
    case invalidCode
    case serverError
    case networkError
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Неверный формат электронной почты"
        case .invalidCode:
            return "Неверный код подтверждения"
        case .serverError:
            return "Ошибка сервера. Попробуйте позже"
        case .networkError:
            return "Ошибка сети. Проверьте подключение"
        case .userNotFound:
            return "Пользователь не найден"
        }
    }
}

// MARK: - API Config

struct APIConfig {
    static let baseURL = "https://hework-api.onrender.com/api"
}
