import UIKit

extension UIViewController {
    /// Same simple `UIAlertController` pattern `LoginViewController` already used
    /// privately, shared here now that more screens need to surface API errors.
    func presentAlert(title: String = String(localized: "Something Went Wrong"), message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK"), style: .default))
        present(alert, animated: true)
    }
}
