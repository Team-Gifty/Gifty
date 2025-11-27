import UIKit
import SnapKit
import Then

protocol SortDropDownViewDelegate: AnyObject {
    func sortButtonTapped(sortOrder: SortOrder)
}

enum SortOrder {
    case byExpiryDate
    case byRegistrationDate
    case byDistance
}

class SortDropDownView: UIView {

    weak var delegate: SortDropDownViewDelegate?
    private var currentSortOrder: SortOrder = .byRegistrationDate

    private let expiryDateButton = UIButton(type: .system)
    private let registrationDateButton = UIButton(type: .system)
    private let distanceButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor(red: 0.992, green: 0.984, blue: 0.965, alpha: 1.0)
        layer.cornerRadius = 8
        layer.borderColor = UIColor(red: 0.937, green: 0.894, blue: 0.827, alpha: 1.0).cgColor
        layer.borderWidth = 1.0
        
        let stackView = UIStackView(arrangedSubviews: [expiryDateButton, registrationDateButton, distanceButton]).then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 4
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
    }

    private func setupButtons() {
        configureButton(expiryDateButton, title: "짧은 유효기간 순", sortOrder: .byExpiryDate)
        configureButton(registrationDateButton, title: "최신 등록 순", sortOrder: .byRegistrationDate)
        configureButton(distanceButton, title: "가까운 거리 순", sortOrder: .byDistance)
        updateButtonSelection()
    }

    private func configureButton(_ button: UIButton, title: String, sortOrder: SortOrder) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .giftyFont(size: 16)
        button.contentHorizontalAlignment = .leading
        
        button.addAction(UIAction { [weak self] _ in
            self?.buttonTapped(sortOrder: sortOrder)
        }, for: .touchUpInside)
    }
    
    private func buttonTapped(sortOrder: SortOrder) {
        self.currentSortOrder = sortOrder
        updateButtonSelection()
        delegate?.sortButtonTapped(sortOrder: sortOrder)
    }

    private func updateButtonSelection() {
        expiryDateButton.setTitleColor(currentSortOrder == .byExpiryDate ? ._6_A_4_C_4_C : .gray, for: .normal)
        registrationDateButton.setTitleColor(currentSortOrder == .byRegistrationDate ? ._6_A_4_C_4_C : .gray, for: .normal)
        distanceButton.setTitleColor(currentSortOrder == .byDistance ? ._6_A_4_C_4_C : .gray, for: .normal)
    }
    
    func set(sortOrder: SortOrder) {
        self.currentSortOrder = sortOrder
        updateButtonSelection()
    }
}
