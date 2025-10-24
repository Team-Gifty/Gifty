
import UIKit

extension UIViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
