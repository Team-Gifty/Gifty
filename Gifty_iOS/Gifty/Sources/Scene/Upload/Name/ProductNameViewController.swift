import UIKit
import SnapKit
import Then
import Combine

class ProductNameViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel = ProductNameViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let productNameTextSubject = CurrentValueSubject<String?, Never>(nil)
    private let confirmButtonTappedSubject = PassthroughSubject<Void, Never>()

    private let titleLabel = UILabel().then {
        $0.text = "교환권 이름(상품명)을 알려주세요!"
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let nameTextField = GiftyTextField(hintText: "상품명")

    private let confirmButton = GiftyButton(buttonText: "확인", isEnabled: true)

    var selectedImageName: String? {
        didSet {
            viewModel.setImageName(selectedImageName)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupBindings()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    // MARK: - Binding
    private func setupBindings() {
        let input = ProductNameViewModel.Input(
            productNameText: productNameTextSubject.eraseToAnyPublisher(),
            confirmButtonTapped: confirmButtonTappedSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.isConfirmButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.confirmButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)

        output.navigationToUsageLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name, imageName in
                guard let self = self else { return }
                let usageLocationVC = UsageLocationViewController()
                usageLocationVC.productName = name
                usageLocationVC.selectedImageName = imageName
                self.navigationController?.pushViewController(usageLocationVC, animated: true)
            }
            .store(in: &cancellables)
    }

    override func addView() {
        [titleLabel, nameTextField, confirmButton, backButton].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }

        nameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        productNameTextSubject.send(nameTextField.text)
    }

    @objc private func confirmButtonTapped() {
        confirmButtonTappedSubject.send(())
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
