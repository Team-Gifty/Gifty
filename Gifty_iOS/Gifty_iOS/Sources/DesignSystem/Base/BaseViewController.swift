import UIKit

open class BaseViewController: UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .FFF_7_EC
    }
    open func addView() {
        // 서브 뷰를 구성하는 함수
    }
    
    open func setLayout() {
        
    }
    
    // MARK: - 키보드 터치 시 숨기기
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // 다른 터치 이벤트 방해하지 않음
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
