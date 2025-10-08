import UIKit
import SnapKit
import Then

class CheckModalViewController: BaseViewController {
    
    let ModalView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.D_0_C_6_C_6.cgColor
        $0.backgroundColor = UIColor.F_7_EAD_8
    }
    
    let CheckImageView = UIImageView().then {
        $0.image = UIImage.check
    }
    
    let CheckLabel = UILabel().then {
        $0.text = "정상적으로 등록되었습니다"
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .giftyFont(size: 23)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func addView() {
        [
            CheckImageView,
            CheckLabel
        ].forEach { ModalView.addSubview($0) }
        
        [
            ModalView
        ].forEach { view.addSubview($0) }
    }
    
    override func setLayout() {
        ModalView.snp.makeConstraints {
            $0.width.equalTo(230)
            $0.height.equalTo(110)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().inset(325)
        }
        CheckImageView.snp.makeConstraints {
            $0.width.height.equalTo(38)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(16)
        }
        CheckLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(CheckImageView.snp.bottom).offset(11)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ModalView.alpha = 0
        
        // 페이드인
        UIView.animate(withDuration: 0.3, animations: {
            self.ModalView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                
            }) { _ in
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}
