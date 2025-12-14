import UIKit
import SnapKit
import Then
import Combine

class MemoViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel = MemoViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let memoTextSubject = CurrentValueSubject<String?, Never>(nil)
    private let registerButtonTappedSubject = PassthroughSubject<Void, Never>()

    private let titleLabel = UILabel().then {
        $0.text = "필요시, 메모를 작성해주세요 :)"
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let memoTextField = GiftyTextField(hintText: "메모 (선택)")

    private let registerButton = GiftyButton(buttonText: "등록", isEnabled: true)

    var productName: String? {
        didSet {
            viewModel.setProductName(productName)
        }
    }

    var usageLocation: String? {
        didSet {
            viewModel.setUsageLocation(usageLocation)
        }
    }

    var expirationDate: Date? {
        didSet {
            viewModel.setExpirationDate(expirationDate)
        }
    }

    var selectedImageName: String? {
        didSet {
            viewModel.setImageName(selectedImageName)
        }
    }

    var latitude: Double? {
        didSet {
            viewModel.setLatitude(latitude)
        }
    }

    var longitude: Double? {
        didSet {
            viewModel.setLongitude(longitude)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupBindings()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        memoTextField.addTarget(self, action: #selector(memoTextDidChange), for: .editingChanged)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }

    // MARK: - Binding
    private func setupBindings() {
        let input = MemoViewModel.Input(
            memoText: memoTextSubject.eraseToAnyPublisher(),
            registerButtonTapped: registerButtonTappedSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.showDuplicateAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showAlert(title: "중복", message: "이미 등록된 교환권 이름입니다.\n다른 이름을 사용해주세요.")
            }
            .store(in: &cancellables)

        output.registrationCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.handleRegistrationComplete()
            }
            .store(in: &cancellables)
    }

    override func addView() {
        [titleLabel, memoTextField, registerButton, backButton].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }

        memoTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        registerButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }

    // MARK: - Actions
    @objc private func memoTextDidChange() {
        memoTextSubject.send(memoTextField.text)
    }

    @objc private func registerButtonTapped() {
        registerButtonTappedSubject.send(())
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func handleRegistrationComplete() {
        if let tabBarController = self.tabBarController {
            if let homeNav = tabBarController.viewControllers?[0] as? UINavigationController,
               let mainVC = homeNav.viewControllers.first as? MainViewController {
                mainVC.ShowCheckModal = true
            }

            if let uploadVC = self.navigationController?.viewControllers.first as? UploadViewController {
                uploadVC.clearInputs()
            }

            if let navController = self.navigationController {
                navController.popToRootViewController(animated: false)
            }

            tabBarController.selectedIndex = 0
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
