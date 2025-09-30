import UIKit
import SnapKit
import Then

struct AppColors {
    static let background = UIColor.clear
    static let hintText = UIColor.B_1_A_4_A_4
    static let selectedTab = UIColor._6_A_4_C_4_C
}

class GiftyTextField: UIView {

    private let textField = UITextField().then {
        $0.borderStyle = .none
        $0.font = UIFont.onboardingFont(size: 20)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = AppColors.background
    }
    
    private let underlineView = UIView().then {
        $0.backgroundColor = AppColors.selectedTab
    }

    var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    var hintText: String = "" {
        didSet {
            textField.placeholder = hintText
        }
    }
    
    var textAlign: NSTextAlignment = .left {
        didSet {
            textField.textAlignment = textAlign
        }
    }
    
    // MARK: - Initializers
    convenience init(hintText: String, textAlign: NSTextAlignment = .left) {
        self.init(frame: .zero)
        self.hintText = hintText
        self.textAlign = textAlign
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        [backgroundView, textField, underlineView].forEach {
            addSubview($0)
        }
        
        // TextField 설정
        textField.placeholder = hintText
        textField.textAlignment = textAlign
        textField.tintColor = AppColors.selectedTab // 커서 색상
        
        // Placeholder 스타일 설정
        if let placeholder = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .font: UIFont.onboardingFont(size: 20),
                    .foregroundColor: AppColors.hintText
                ]
            )
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 배경 뷰
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 텍스트 필드 (bottom에 8pt 패딩)
        textField.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().offset(-8)
            $0.centerX.equalToSuperview()
        }
        
        // 언더라인 (2pt 높이)
        underlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.width.equalTo(180)
        }
        
        // 전체 높이
        self.snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }
    
    var delegate: UITextFieldDelegate? {
            get { return textField.delegate }
            set { textField.delegate = newValue }
        }
}
