import UIKit
import SnapKit
import Then

class UploadViewController: BaseViewController {
    
    
    let photoDescriptionLabel = UILabel().then {
        $0.text = "등록할 교환권 이미지를 넣어주세요 :)"
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .giftyFont(size: 25)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    
    let imageuploadButton = UIButton().then {
        $0.setTitle("탭하여 교환권 넣기", for: .normal)
        $0.setTitleColor(.BFA_98_A, for: .normal)
        $0.titleLabel?.font = .giftyFont(size: 23)
        $0.backgroundColor = .F_7_EAD_8
        $0.layer.cornerRadius = 15
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 100
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    
    let informationButton = GiftyButton(
        buttonText: "정보 작성하기",
        isEnabled: false,
        height: 50
    )
    
    
    let uploadButton = GiftyButton(
        buttonText: "등록",
        isEnabled: false,
        height: 50
    )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func addView() {
        [
            photoDescriptionLabel,
            imageuploadButton,
            informationButton,
            uploadButton
        ].forEach { view.addSubview($0) }
        
    }
    
    override func setLayout() {
        photoDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(75)
        }
        
        imageuploadButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(photoDescriptionLabel.snp.bottom).offset(16)
            $0.width.equalTo(287)
            $0.height.equalTo(323)
        }
        
        informationButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(50)
            $0.top.equalTo(imageuploadButton.snp.bottom).offset(25)
        }
        
        uploadButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(50)
            $0.top.equalTo(informationButton.snp.bottom).offset(14)
        }
    }
    
    
    
}
