import UIKit
import Combine
import SnapKit
import Then

final class LoginViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "Gifty"
        $0.font = .systemFont(ofSize: 48, weight: .bold)
        $0.textColor = ._6_A_4_C_4_C
        $0.textAlignment = .center
    }

    private let subtitleLabel = UILabel().then {
        $0.text = "로그인하여 시작하기"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .B_1_A_4_A_4
        $0.textAlignment = .center
    }

    private let emailTextField = GiftyTextField(
        hintText: "이메일",
        textAlign: .left
    ).then {
        $0.innerTextField.keyboardType = .emailAddress
        $0.innerTextField.autocapitalizationType = .none
    }

    private let passwordTextField = GiftyTextField(
        hintText: "비밀번호",
        textAlign: .left
    ).then {
        $0.innerTextField.isSecureTextEntry = true
    }

    private let loginButton = GiftyButton(
        buttonText: "로그인",
        isEnabled: false,
        height: 50
    )

    private let activityIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = ._6_A_4_C_4_C
    }

    // MARK: - Subjects
    private let emailSubject = PassthroughSubject<String, Never>()
    private let passwordSubject = PassthroughSubject<String, Never>()
    private let loginButtonTappedSubject = PassthroughSubject<Void, Never>()

    // MARK: - Init
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupButton()
        bind()
    }

    // MARK: - Setup
    override func addView() {
        [titleLabel, subtitleLabel, emailTextField, passwordTextField, loginButton, activityIndicator].forEach {
            view.addSubview($0)
        }
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            $0.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(60)
            $0.leading.trailing.equalToSuperview().inset(40)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(40)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.height.equalTo(50)
        }

        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setupTextField() {
        emailTextField.innerTextField.addTarget(
            self,
            action: #selector(emailTextFieldDidChange),
            for: .editingChanged
        )

        passwordTextField.innerTextField.addTarget(
            self,
            action: #selector(passwordTextFieldDidChange),
            for: .editingChanged
        )
    }

    private func setupButton() {
        loginButton.buttonTap = { [weak self] in
            self?.loginButtonTappedSubject.send(())
        }
    }

    // MARK: - Binding
    private func bind() {
        let input = LoginViewModel.Input(
            emailText: emailSubject.eraseToAnyPublisher(),
            passwordText: passwordSubject.eraseToAnyPublisher(),
            loginButtonTapped: loginButtonTappedSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.isLoginButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.loginButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)

        output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.view.isUserInteractionEnabled = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
            }
            .store(in: &cancellables)

        output.loginResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.handleLoginSuccess()
                case .failure(let error):
                    self?.handleLoginFailure(error: error)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions
    @objc private func emailTextFieldDidChange() {
        emailSubject.send(emailTextField.text ?? "")
    }

    @objc private func passwordTextFieldDidChange() {
        passwordSubject.send(passwordTextField.text ?? "")
    }

    private func handleLoginSuccess() {
        print("✅ 로그인 성공!")
        // TODO: 메인 화면으로 이동
        showAlert(title: "성공", message: "로그인에 성공했습니다!")
    }

    private func handleLoginFailure(error: Error) {
        print("❌ 로그인 실패: \(error.localizedDescription)")
        showAlert(title: "실패", message: "로그인에 실패했습니다.\n\(error.localizedDescription)")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
