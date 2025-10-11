import UIKit
import SnapKit
import Then

class GifticonViewController: BaseViewController {
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "Test")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
    }
    
    private let shadowView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 15
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 1
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    
    private let productLabel = UILabel().then {
        $0.text = "상품명"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }
    
    private let productcontentLabel = UILabel().then {
        $0.text = "상품명 내용"
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    private  let storeLabel = UILabel().then {
        $0.text = "사용처"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }
    
    private let storecontentLabel = UILabel().then {
        $0.text = "사용처 내용"
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    private  let expiryLabel = UILabel().then {
        $0.text = "유효기간"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }
    
    private   let expirycontentLabel = UILabel().then {
        $0.text = "유효기간 내용"
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    private let memoLabel = UILabel().then {
        $0.text = "메모"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }
    
    private let memocontentLabel = UILabel().then {
        $0.text = "등록된 메모가 없어요"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }
    
    private let pView = UIView()
    private   let sView = UIView()
    private    let eView = UIView()
    private  let mView = UIView()
    private  let contentView = UIView()
    
    private   let modifyButton = UIButton().then {
        $0.setImage(UIImage(named: "Modify"), for: .normal)
    }
    
    private  let shareButton = UIButton().then {
        $0.setImage(UIImage(named: "Share"), for: .normal)
    }
    
    private  let deleteButton = UIButton().then {
        $0.setImage(UIImage(named: "Delete"), for: .normal)
        $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    private let exitButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func addView() {
        
        shadowView.addSubview(imageView)
        pView.addSubview(productLabel)
        pView.addSubview(productcontentLabel)
        sView.addSubview(storeLabel)
        sView.addSubview(storecontentLabel)
        eView.addSubview(expiryLabel)
        eView.addSubview(expirycontentLabel)
        mView.addSubview(memoLabel)
        mView.addSubview(memocontentLabel)
        
        [
            contentView,
            shadowView,
            modifyButton,
            shareButton,
            deleteButton,
            exitButton
        ].forEach { view.addSubview($0) }
        
        [
            pView,
            sView,
            eView,
            mView
        ].forEach { contentView.addSubview($0) }
    }
    
    
    override func setLayout() {
        
        shadowView.snp.makeConstraints {
            $0.width.equalTo(287)
            $0.height.equalTo(323)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(118)
        }
        
        imageView.snp.makeConstraints {
            $0.width.equalTo(287)
            $0.height.equalTo(323)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(118)
        }
        
        productLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        
        productcontentLabel.snp.makeConstraints {
            $0.leading.equalTo(productLabel.snp.trailing).offset(42)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        pView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
        }
        
        storeLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        
        storecontentLabel.snp.makeConstraints {
            $0.leading.equalTo(storeLabel.snp.trailing).offset(42)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        sView.snp.makeConstraints {
            $0.top.equalTo(pView.snp.bottom).offset(14)
        }
        
        expiryLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        
        expirycontentLabel.snp.makeConstraints {
            $0.leading.equalTo(expiryLabel.snp.trailing).offset(30)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        eView.snp.makeConstraints {
            $0.top.equalTo(sView.snp.bottom).offset(14)
        }
        
        memoLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        
        memocontentLabel.snp.makeConstraints {
            $0.leading.equalTo(memoLabel.snp.trailing).offset(55)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        mView.snp.makeConstraints {
            $0.top.equalTo(eView.snp.bottom).offset(14)
        }
        
        contentView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(shadowView.snp.bottom).offset(40)
            $0.width.equalTo(245)
            $0.height.equalTo(234)
        }
        
        modifyButton.snp.makeConstraints {
            $0.trailing.equalTo(shadowView.snp.trailing)
            $0.bottom.equalTo(shadowView.snp.top).offset(-11)
        }
        
        shareButton.snp.makeConstraints {
            $0.trailing.equalTo(modifyButton.snp.leading).offset(-10)
            $0.bottom.equalTo(shadowView.snp.top).offset(-11)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalTo(shareButton.snp.leading).offset(-10)
            $0.bottom.equalTo(shadowView.snp.top).offset(-11)
        }
        
        exitButton.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(74)
            $0.leading.equalToSuperview().inset(34)
        }
        
    }
    
    @objc
    private func deleteButtonTapped() {
        
        let dimView = UIView()
        dimView.backgroundColor = UIColor._5_C_5_C_5_C.withAlphaComponent(0.45)
        dimView.frame = view.bounds
        dimView.alpha = 0
        view.addSubview(dimView)
        
        UIView.animate(withDuration: 0.25) {
            dimView.alpha = 1
        } completion: { _ in
            
            // 검은 뷰를 그냥 하나 만들고 그 뷰가 먼저 뜨게 끔
            
            
            let deleteModalVC = DeleteModalViewController()
            deleteModalVC.modalPresentationStyle = .overFullScreen
            //  deleteModalVC.view.backgroundColor = UIColor._5_C_5_C_5_C.withAlphaComponent(0.45)
            self.present(deleteModalVC, animated: true, completion: nil)
        }
        
    }
    
}
