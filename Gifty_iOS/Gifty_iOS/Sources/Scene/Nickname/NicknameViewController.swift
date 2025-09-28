import UIKit
import SnapKit
import Then


class NicknameViewController: BaseViewController {
    
    let nicknameLabel = UILabel().then {
        $0.text = "사용하실 닉네임을 입력해주세요!"
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .onboardingFont(size: 25)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    let nicknameField = GiftyTextField(
        hintText: "닉네임 입력",
        textAlign: .center
    )
    
    let nicknameButton = GiftyButton(
        buttonText: "저장",
        isEnabled: false,
        height: 50
    )
    
    override func addView() {
        [
            nicknameLabel,
            nicknameField,
            nicknameButton
        ].forEach { view.addSubview($0) }
    }
    
    override func setLayout() {
        nicknameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(276)
        }
        nicknameField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(31)
        }
        nicknameButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(27)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(7)
        }
    }
    
    // textField 상태에 따라 LoginButton 상태 활성화 유
    func textFieldDidChangeSelection(_ nicknameField: UITextField) {
        if (nicknameField.text?.count ?? 0 < 1) || (loginView.passwordTextField.text?.count ?? 0 < 1) {
            updateLoginButtonState(isEnabled: false, backgroundColor: .tvingBlack, borderColor: .tvingGray4)
        } else {
            updateLoginButtonState(isEnabled: true, backgroundColor: .tvingRed, borderColor: .clear)
        }
    }

    func updateLoginButtonState(isEnabled: Bool, backgroundColor: UIColor, borderColor: UIColor) {
        loginView.loginButton.isEnabled = isEnabled
        loginView.loginButton.backgroundColor = backgroundColor
        loginView.loginButton.layer.borderColor = borderColor.cgColor
    }
}
