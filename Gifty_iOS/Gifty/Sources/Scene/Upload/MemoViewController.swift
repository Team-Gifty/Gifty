
import UIKit
import SnapKit
import Then

class MemoViewController: BaseViewController {

    private let titleLabel = UILabel().then {
        $0.text = "필요시, 메모를 작성해주세요 :)"
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let memoTextField = GiftyTextField(hintText: "메모 (선택)")

    private let registerButton = GiftyButton(buttonText: "등록", isEnabled: true)
    
    private let viewModel = UploadViewModel()
    
    var productName: String?
    var usageLocation: String?
    var expirationDate: Date?
    var selectedImageName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }

    override func addView() {
        [titleLabel, memoTextField, registerButton].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }

        memoTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        registerButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    @objc private func registerButtonTapped() {
        guard let name = productName,
              let usage = usageLocation,
              let expiryDate = expirationDate,
              let imageName = selectedImageName else { return }
        
        let memo = memoTextField.text
        
        if RealmManager.shared.isDuplicateGiftName(name) {
            showAlert(title: "중복", message: "이미 등록된 교환권 이름입니다.\n다른 이름을 사용해주세요.")
            return
        }
        
        if let newGift = viewModel.saveGift(name: name, usage: usage, expiryDate: expiryDate, memo: memo, imagePath: imageName) {
            NotificationManager.shared.scheduleImmediateNotification(for: newGift)
            NotificationManager.shared.scheduleDailySummaryNotification()
            NotificationCenter.default.post(name: .giftRegistered, object: nil)
        }
        
        if let mainVC = self.navigationController?.tabBarController?.viewControllers?[0] as? MainViewController {
            mainVC.ShowCheckModal = true
        }
        
        self.navigationController?.popToRootViewController(animated: false)
        self.tabBarController?.selectedIndex = 0
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
