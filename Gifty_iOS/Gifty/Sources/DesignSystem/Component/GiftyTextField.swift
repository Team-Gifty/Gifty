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

    private func setupView() {
        [backgroundView, textField, underlineView].forEach {
            addSubview($0)
        }

        textField.placeholder = hintText
        textField.textAlignment = textAlign
        textField.tintColor = AppColors.selectedTab
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
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        textField.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().offset(-8)
            $0.centerX.equalToSuperview()
        }

        underlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.width.equalTo(180)
        }

        self.snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }

    var delegate: UITextFieldDelegate? {
            get { return textField.delegate }
            set { textField.delegate = newValue }
        }

    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        textField.addTarget(target, action: action, for: controlEvents)
    }

    var innerTextField: UITextField {
        return textField
    }
}
