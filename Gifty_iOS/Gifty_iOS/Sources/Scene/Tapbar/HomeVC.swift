
import UIKit
import SnapKit
import Then

class HomeVC: UIViewController {
    
    let messageLabel = UILabel().then {
        $0.text = "Home View"
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .giftyFont(size: 24)
    }
    
    let boxImageView = UIImageView().then{
        $0.image = UIImage(named: "box")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .FFF_7_EC
        
        view.addSubview(messageLabel)
        view.addSubview(boxImageView)
        
        
        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(350)
        }
        
        boxImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(messageLabel.snp.bottom).offset(20)
        }
    }
}

