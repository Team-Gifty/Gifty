import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class NicknameViewController: BaseViewController {

    private let viewModel = NicknameViewModel()
    private let disposeBag = DisposeBag()
    private let viewWillAppearTrigger = PublishSubject<Void>()

    let nicknameLabel = UILabel().then {
        $0.text = "사용하실 닉네임을 입력해주세요!"
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .onboardingFont(size: 25)
        $0.textColor = ._6_A_4_C_4_C
    }

    let nicknameField = GiftyTextField(
        hintText: "닉네임 입력",
        textAlign: .center
    )

    let nicknameButton = GiftyButton(
        buttonText: "저장",
        isEnabled: false,
        height: 50
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        bind()
        bindKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearTrigger.onNext(())
    }

    override func addView() {
        [
            nicknameLabel,
            nicknameField,
            nicknameButton
        ].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        nicknameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(120)
        }
        nicknameField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(31)
        }
        nicknameButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(27)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(7)
        }
    }

    private func bind() {
        let input = NicknameViewModel.Input(
            nicknameText: nicknameField.rx.text.orEmpty.asObservable(),
            saveButtonTap: nicknameButton.rx.tap.asObservable(),
            viewWillAppear: viewWillAppearTrigger.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isButtonEnabled
            .drive(nicknameButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.isButtonEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.nicknameButton.backgroundColor = isEnabled ? .FDE_1_AD : .lightGray
                self?.nicknameButton.setTitleColor(isEnabled ? .A_98_E_5_C : .darkGray, for: .normal)
            })
            .disposed(by: disposeBag)

        output.loadedNickname
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] nickname in
                self?.nicknameField.text = nickname
                print("✅ 저장된 닉네임 불러오기: \(nickname)")
            })
            .disposed(by: disposeBag)

        output.saveCompleted
            .subscribe(onNext: { [weak self] nickname in
                self?.showSaveAlert(nickname: nickname)
            })
            .disposed(by: disposeBag)
    }

    private func bindKeyboard() {
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }

        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(7) }

        Observable.merge(keyboardWillShow, keyboardWillHide)
            .subscribe(onNext: { [weak self] bottomInset in
                guard let self = self else { return }
                self.nicknameButton.snp.updateConstraints {
                    $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(bottomInset)
                }
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }

    private func showSaveAlert(nickname: String) {
        let alert = UIAlertController(
            title: "저장 완료",
            message: "닉네임 '\(nickname)'이(가) 저장되었습니다!",
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.goToMainScreen()
        }
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }

    private func goToMainScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }

        let tabBarController = GiftyTabBarController()
        let navController = UINavigationController(rootViewController: tabBarController)

        UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
            sceneDelegate.window?.rootViewController = navController
        })
    }
}
