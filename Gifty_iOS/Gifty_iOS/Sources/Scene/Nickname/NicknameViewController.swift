import UIKit
import SnapKit
import Then


class NicknameViewController: BaseViewController {
    
    var nicknameState: Bool = false
    
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
//
//    
//    override func addView() {
//        [
//            nicknameLabel,
//            nicknameField,
//            nicknameButton
//        ].forEach { view.addSubview($0) }
//        
//        nicknameField.addTarget(self, action: #selector(textFieldDidChangeSelection(_:)), for: .editingChanged)
//
//
//    }
    
    
    override func addView() {
        [
            nicknameLabel,
            nicknameField,
            nicknameButton
        ].forEach { view.addSubview($0) }
        
        nicknameField.delegate = self
    }
    

//    
//    // textField 상태에 따라 LoginButton 상태 활성화 유
//    @objc func textFieldDidChangeSelection(_ nicknameField: UITextField) {
//        if (nicknameField.text?.count ?? 0 < 1) {
//            updateNicknameButtonState(isEnabled: false, backgroundColor: .FCEDD_0, borderColor: .DDC_495)
//        } else {
//            updateNicknameButtonState(isEnabled: true, backgroundColor: .FDE_1_AD, borderColor: .A_98_E_5_C)
//        }
//    }
//
//    func updateNicknameButtonState(isEnabled: Bool, backgroundColor: UIColor, borderColor: UIColor) {
//        nicknameButton.isEnabled = isEnabled
//        nicknameButton.backgroundColor = backgroundColor
//        nicknameButton.layer.borderColor = borderColor.cgColor
//    }
//
//}


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

    func updateNicknameButtonState(isEnabled: Bool, backgroundColor: UIColor, textColor: UIColor) {
        nicknameButton.isEnabled = isEnabled
        nicknameButton.backgroundColor = backgroundColor
        nicknameButton.setTitleColor(textColor, for: .normal)
    }

}

// MARK: - UITextFieldDelegate
extension NicknameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count < 1 {
            updateNicknameButtonState(isEnabled: false, backgroundColor: .FCEDD_0, textColor: .DDC_495)
        } else {
            updateNicknameButtonState(isEnabled: true, backgroundColor: .FDE_1_AD, textColor: .A_98_E_5_C)
        }
        
        return true
    }
}
