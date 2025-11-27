
import UIKit
import SnapKit
import Then

class MemoViewController: BaseViewController {

    private let titleLabel = UILabel().then {
        $0.text = "필요시, 메모를 작성해주세요 :)"
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let memoTextField = GiftyTextField(hintText: "메모 (선택)")

    private let registerButton = GiftyButton(buttonText: "등록", isEnabled: true)
    
    private let viewModel = UploadViewModel()
    
    var productName: String?
    var usageLocation: String?
    var expirationDate: Date?
    var selectedImageName: String?
    var latitude: Double?
    var longitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }

    override func addView() {
        [titleLabel, memoTextField, registerButton, backButton].forEach { view.addSubview($0) }
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }

    @objc private func registerButtonTapped() {
        guard let name = productName,
              let usage = usageLocation,
              let expiryDate = expirationDate,
              let imageName = selectedImageName else {
            return
        }
        
        let memo = memoTextField.text
        
        if RealmManager.shared.isDuplicateGiftName(name) {
            showAlert(title: "중복", message: "이미 등록된 교환권 이름입니다.\n다른 이름을 사용해주세요.")
            return
        }
        
        if let newGift = viewModel.saveGift(name: name, usage: usage, expiryDate: expiryDate, memo: memo, imagePath: imageName, latitude: latitude, longitude: longitude) {
            NotificationManager.shared.scheduleImmediateNotification(for: newGift)
            NotificationManager.shared.scheduleDailySummaryNotification()

            if latitude != nil && longitude != nil {
                GeofenceManager.shared.addGeofence(for: newGift)
            }
        }
        
        if let tabBarController = self.tabBarController {
            if let homeNav = tabBarController.viewControllers?[0] as? UINavigationController,
               let mainVC = homeNav.viewControllers.first as? MainViewController {
                mainVC.ShowCheckModal = true
            }

            if let uploadVC = self.navigationController?.viewControllers.first as? UploadViewController {
                uploadVC.clearInputs()
            }

            if let navController = self.navigationController {
                navController.popToRootViewController(animated: false)
            }

            tabBarController.selectedIndex = 0
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
