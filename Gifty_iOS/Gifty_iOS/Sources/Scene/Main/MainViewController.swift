import UIKit
import SnapKit
import Then

class MainViewController: BaseViewController {
    
    
    let iconImageView = UIImageView().then {
        $0.image = UIImage(named: "GiftyBox")
    }
    
    let titleLabel = UILabel().then {
        $0.text = "이거주희님의 교환권"
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .nicknameFont(size: 15)
    }
    
    
    let noneLabel = UILabel().then {
        $0.text = "아직 등록된 교환권이 없어요"
        $0.textColor = ._7_F_7_D_7_D
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .giftyFont(size: 28)
    }
    
    let boxImageView = UIImageView().then {
        $0.image = UIImage(named: "EmptyBox")
    }
    
   
       override func viewDidLoad() {
           super.viewDidLoad()
       }
       
    
    override func addView() {
        [
            iconImageView,
            titleLabel,
            noneLabel,
            boxImageView
        ].forEach { view.addSubview($0) }
        
    }
    
    override func setLayout() {
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(64)
            $0.leading.equalToSuperview().inset(34)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(74)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
        }
        
        noneLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(281)
        }
        
        boxImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(noneLabel.snp.top).offset(-49)
            $0.width.equalTo(124.11)
            $0.height.equalTo(113)
        }
    }

    
}
