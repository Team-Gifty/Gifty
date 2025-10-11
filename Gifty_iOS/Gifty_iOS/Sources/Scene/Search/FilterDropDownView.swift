
import UIKit
import SnapKit
import Then

protocol FilterDropDownViewDelegate: AnyObject {
    func filterButtonTapped(filter: SearchFilter)
}

enum SearchFilter {
    case productName
    case usage
}

class FilterDropDownView: UIView {
    
    weak var delegate: FilterDropDownViewDelegate?
    private var currentFilter: SearchFilter = .productName

    private let productNameButton = UIButton(type: .system)
    private let usageButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor(red: 1.0, green: 0.969, blue: 0.925, alpha: 1.0) // #FFF7EC
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        let stackView = UIStackView(arrangedSubviews: [productNameButton, usageButton]).then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 2
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
    }

    private func setupButtons() {
        configureButton(productNameButton, title: "상품명 검색", iconName: "tag", filter: .productName)
        configureButton(usageButton, title: "사용처 검색", iconName: "house", filter: .usage)
        updateButtonSelection()
    }

    private func configureButton(_ button: UIButton, title: String, iconName: String, filter: SearchFilter) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(named: iconName)
        config.imagePadding = 6
        config.baseForegroundColor = UIColor(red: 0.416, green: 0.302, blue: 0.302, alpha: 1.0) // #6A4C4C
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .giftyFont(size: 15)
            return outgoing
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        button.layer.cornerRadius = 5
        
        button.addAction(UIAction { [weak self] _ in
            self?.buttonTapped(filter: filter)
        }, for: .touchUpInside)
    }
    
    private func buttonTapped(filter: SearchFilter) {
        self.currentFilter = filter
        updateButtonSelection()
        delegate?.filterButtonTapped(filter: filter)
    }

    private func updateButtonSelection() {
        productNameButton.backgroundColor = (currentFilter == .productName) ? UIColor(red: 0.945, green: 0.906, blue: 0.855, alpha: 1.0) : .clear // #F1E7DA
        usageButton.backgroundColor = (currentFilter == .usage) ? UIColor(red: 0.945, green: 0.906, blue: 0.855, alpha: 1.0) : .clear // #F1E7DA
    }
    
    func set(filter: SearchFilter) {
        self.currentFilter = filter
        updateButtonSelection()
    }
}
