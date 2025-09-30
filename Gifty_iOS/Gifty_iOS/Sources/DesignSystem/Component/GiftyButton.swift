import UIKit
import SnapKit
import Then

public class GiftyButton: UIButton {

    public var buttonTap: (() -> Void)?
    
    public override var isEnabled: Bool {
        
        didSet {
            
            attribute()
            
        }
        
    }
    
    private var bgColor: UIColor {
        
        isEnabled ? UIColor(named: "FDE1AD") ?? .systemBrown : UIColor(named: "FCEDD0") ?? .lightGray
        
    }
    
    override public init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupButton()
        
    }
    
    convenience public init(
        
        type: UIButton.ButtonType? = .system,
        
        buttonText: String? = String(),
        
        isEnabled: Bool? = true,
        
        isHidden: Bool? = false,
        
        height: CGFloat? = 47
        
    ) {
        
        self.init(type: .system)
        
        self.setTitle(buttonText, for: .normal)
        
        self.isEnabled = isEnabled ?? true
        
        self.isHidden = isHidden ?? false
        
        attribute()
        
        self.snp.remakeConstraints {
            
            $0.height.equalTo(height ?? 0)
            
        }
        
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        attribute()
        
    }
    
    private func setupButton() {
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        attribute()
        
    }
    
    @objc private func buttonTapped() {
        
        buttonTap?()
        
    }
    
    public func attribute() {
        
        self.backgroundColor = bgColor
        
//        self.setTitleColor(UIColor(named: "DDC495") ?? .white, for: .normal)
        
        self.titleLabel?.font = .onboardingFont(size: 23)
        
        self.layer.cornerRadius = 8
        
    }
    
}

//import UIKit
//import SnapKit
//import Then
//
//
//public class GiftyButton: UIButton {
//
//    // 버튼 탭 콜백
//    public var buttonTap: (() -> Void)?
//
//    // 상태별 색상 정의
//    private let enabledBackgroundColor = UIColor(named: "FDE1AD") ?? .systemBrown
//    private let disabledBackgroundColor = UIColor(named: "FCEDD0") ?? .lightGray
//    private let enabledTextColor = UIColor(named: "A98E5C") ?? .black
//    private let disabledTextColor = UIColor.darkGray
//
//    // isEnabled가 바뀔 때 UI 자동 변경
//    public override var isEnabled: Bool {
//        didSet {
//            updateUIForState()
//        }
//    }
//
//    // 초기화
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupButton()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // 버튼 기본 설정
//    private func setupButton() {
//        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//        self.layer.cornerRadius = 8
//        self.titleLabel?.font = .onboardingFont(size: 23)
//        updateUIForState()  // 초기 상태 UI 적용
//    }
//
//    @objc private func buttonTapped() {
//        buttonTap?()
//    }
//
//    // 상태별 UI 업데이트
//    private func updateUIForState() {
//        self.backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
//        self.setTitleColor(isEnabled ? enabledTextColor : disabledTextColor, for: .normal)
//    }
//
//}
