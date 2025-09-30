
import UIKit
import SnapKit
import Then

class SearchVC: UIViewController {
    
    let messageLabel = UILabel().then {
        $0.text = "Search View"
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .giftyFont(size: 24)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .FFF_7_EC
        
        view.addSubview(messageLabel)
        
        
        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(350)
        }
    }
}

