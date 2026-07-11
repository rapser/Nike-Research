import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case invalidForm
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "The email or password you entered is incorrect."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .weakPassword:
            return "Your password must be at least 6 characters."
        case .invalidForm:
            return "Please fill in all fields correctly."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
