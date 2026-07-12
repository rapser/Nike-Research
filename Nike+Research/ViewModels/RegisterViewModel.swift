import Foundation

final class RegisterViewModel {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var onRegisterSucceeded: (() -> Void)?

    var title: String { String(localized: "SIGN UP") }

    var isValid: Bool {
        !name.isEmpty &&
        email.contains("@") && email.contains(".") &&
        password.count >= 6 &&
        password == confirmPassword
    }

    func register(completion: @escaping (AuthError?) -> Void) {
        AuthService.shared.register(name: name, email: email, password: password) { result in
            switch result {
            case .success:
                completion(nil)
                self.onRegisterSucceeded?()
            case .failure(let error):
                completion(error)
            }
        }
    }
}
