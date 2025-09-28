import UIKit
import SnapKit
import Then


class NicknameViewController: BaseViewController {
    
    let NicknameLabel = UILabel().then {
        $0.text = "사용하실 닉네임을 입력해주세요!"
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .onboardingFont(size: 25)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    
}
