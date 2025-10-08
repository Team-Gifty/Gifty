import UIKit

class BottomSheetViewController: UIViewController {
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("닫기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var sheetTitle: String = "바텀시트"
    var sheetContent: String = "바텀시트 내용입니다."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        containerView.addSubview(handleView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        containerView.addSubview(closeButton)
        
        titleLabel.text = sheetTitle
        contentLabel.text = sheetContent
        
        NSLayoutConstraint.activate([
            // Dimmed View
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Container View
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 350),
            
            // Handle View
            handleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Content Label
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Close Button
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSheet))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissSheet() {
        dismiss(animated: true)
    }
}

// MARK: - 사용 예시
class ExampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let showButton = UIButton(type: .system)
        showButton.setTitle("바텀시트 열기", for: .normal)
        showButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        showButton.backgroundColor = .systemBlue
        showButton.setTitleColor(.white, for: .normal)
        showButton.layer.cornerRadius = 8
        showButton.addTarget(self, action: #selector(showBottomSheet), for: .touchUpInside)
        
        view.addSubview(showButton)
        showButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            showButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showButton.widthAnchor.constraint(equalToConstant: 200),
            showButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func showBottomSheet() {
        let bottomSheet = BottomSheetViewController()
        bottomSheet.sheetTitle = "알림"
        bottomSheet.sheetContent = "이것은 바텀시트 예시입니다.\n여러 줄의 텍스트를 표시할 수 있습니다."
        bottomSheet.modalPresentationStyle = .overFullScreen
        present(bottomSheet, animated: true)
    }
}
