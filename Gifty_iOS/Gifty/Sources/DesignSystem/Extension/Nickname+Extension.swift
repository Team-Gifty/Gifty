import UIKit

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
