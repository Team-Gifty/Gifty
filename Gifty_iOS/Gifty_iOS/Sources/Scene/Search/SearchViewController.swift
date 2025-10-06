import UIKit
import SnapKit
import Then

class SearchViewController: BaseViewController {
    
    let searchTextField = UITextField().then {
        $0.placeholder = "검색"
        $0.textColor = ._6_A_4_C_4_C
        $0.backgroundColor = UIColor.EFE_4_D_3
        $0.layer.cornerRadius = 8
        $0.font = .giftyFont(size: 28)
        
        $0.attributedPlaceholder = NSAttributedString(
            string: "검색",
            attributes: [
                .foregroundColor: UIColor.CAC_2_B_7,
                .font: UIFont.giftyFont(size: 28)
            ]
        )
        
        
        let leftImageView = UIImageView(image: UIImage(named: "searchField"))
        leftImageView.contentMode = .scaleAspectFit
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 24))
        leftImageView.frame = CGRect(x: 20, y: 2, width: 20, height: 20)
        leftContainer.addSubview(leftImageView)

        $0.leftView = leftContainer
        $0.leftViewMode = .always
        
        let rightButton = UIButton()
        rightButton.setImage(UIImage(named: "Filter"), for: .normal)
        rightButton.imageView?.contentMode = .scaleAspectFit
        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        rightButton.frame = CGRect(x: 0, y: 4, width: 21.27, height: 13)
        rightContainer.addSubview(rightButton)

        // 텍스트필드 오른쪽에 버튼 추가
        $0.rightView = rightContainer
        $0.rightViewMode = .always
        
    }
    
    let searchDescriptionLabel = UILabel().then {
        $0.text = "원하는 필터링으로 검색해보세요!"
        $0.textColor = ._7_F_7_D_7_D
        $0.font = .giftyFont(size: 28)
    }

    
    override func addView() {
        [
            searchTextField,
            searchDescriptionLabel
        ].forEach { view.addSubview($0) }
    }
    
    override func setLayout() {
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-32)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.height.equalTo(50)
        }
        
        searchDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(searchTextField.snp.bottom).offset(246)
        }
    }
}
