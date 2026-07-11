import Foundation

/// Simulates a network-backed auth API: validates input, waits briefly to mimic latency,
/// and resolves through the same `Result` completion shape a real HTTP client would use.
///
/// Since there's no backend yet, the "user database" itself is persisted to `UserDefaults`
/// (separately from the active session in `AuthService`) so the full register -> log out ->
/// relaunch -> log back in flow works end-to-end without a server.
final class DummyAuthRepository: AuthRepository {
    private let simulatedLatency: TimeInterval = 0.6
    private let userDefaultsKey = "nike.auth.registeredUsers"

    private struct StoredAccount: Codable {
        let password: String
        let user: User
    }

    private var registeredUsers: [String: StoredAccount] {
        didSet { persistAccounts() }
    }

    init() {
        registeredUsers = Self.loadPersistedAccounts(key: userDefaultsKey) ?? Self.seedAccounts()
    }

    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedLatency) {
            guard let account = self.registeredUsers[normalizedEmail], account.password == password else {
                completion(.failure(.invalidCredentials))
                return
            }
            completion(.success(account.user))
        }
    }

    func register(name: String, email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedLatency) {
            guard self.registeredUsers[normalizedEmail] == nil else {
                completion(.failure(.emailAlreadyInUse))
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let memberSince = "Member since \(dateFormatter.string(from: Date()))"
            let user = User(id: UUID().uuidString, name: name, email: normalizedEmail, memberSince: memberSince)
            self.registeredUsers[normalizedEmail] = StoredAccount(password: password, user: user)
            completion(.success(user))
        }
    }

    private func persistAccounts() {
        guard let data = try? JSONEncoder().encode(registeredUsers) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    private static func loadPersistedAccounts(key: String) -> [String: StoredAccount]? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let accounts = try? JSONDecoder().decode([String: StoredAccount].self, from: data),
              !accounts.isEmpty else { return nil }
        return accounts
    }

    private static func seedAccounts() -> [String: StoredAccount] {
        [
            "jordan@nike.com": StoredAccount(
                password: "password123",
                user: User(id: UUID().uuidString, name: "Jordan Runner", email: "jordan@nike.com", memberSince: "Member since 2019")
            )
        ]
    }
}
