
import UIKit
import SnapKit
import Then

class ProductNameViewController: BaseViewController {

    private let titleLabel = UILabel().then {
        $0.text = "교환권 이름(상품명)을 알려주세요!"
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let nameTextField = GiftyTextField(hintText: "상품명")

    private let confirmButton = GiftyButton(buttonText: "확인", isEnabled: true)
    
    var selectedImageName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        updateButtonState()
    }

    override func addView() {
        [titleLabel, nameTextField, confirmButton, backButton].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }

        nameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }
    
    private func updateButtonState() {
        let isEmpty = nameTextField.text?.isEmpty ?? true
        confirmButton.isEnabled = !isEmpty
    }

    @objc private func textFieldDidChange() {
        updateButtonState()
    }

    @objc private func confirmButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }

        let usageLocationVC = UsageLocationViewController()
        usageLocationVC.productName = name
        usageLocationVC.selectedImageName = selectedImageName
        navigationController?.pushViewController(usageLocationVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
