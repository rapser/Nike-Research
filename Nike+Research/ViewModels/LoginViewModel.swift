import Foundation

final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    var onLoginSucceeded: (() -> Void)?

    var title: String { "LOG IN" }

    var isValid: Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    func login(completion: @escaping (AuthError?) -> Void) {
        AuthService.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                completion(nil)
                self.onLoginSucceeded?()
            case .failure(let error):
                completion(error)
            }
        }
    }
}
