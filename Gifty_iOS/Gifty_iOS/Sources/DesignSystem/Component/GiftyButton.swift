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
        
        // 상태에 따라 글자색 변경
        let titleColor: UIColor = isEnabled
        ? UIColor(named: "A98E5C") ?? .white        // 활성
        : UIColor(named: "DDC495") ?? .lightGray   // 비활성
        
        self.setTitleColor(titleColor, for: .normal)
        
        self.backgroundColor = bgColor
        //   self.setTitleColor(UIColor(named: "A98E5C") ?? .white, for: .normal)
        self.titleLabel?.font = .onboardingFont(size: 23)
        self.layer.cornerRadius = 8
    }
}
