import UIKit

open class BaseViewController: UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .FFF_7_EC
        addView()
        setLayout()
    }

    open func addView() {}
    open func setLayout() {}

    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
}
