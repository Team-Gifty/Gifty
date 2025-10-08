import UIKit
import SnapKit
import Then
import RealmSwift

class NicknameViewController: BaseViewController {
    
    var nicknameState: Bool = false
    
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
        loadNickname()
    }

    override func addView() {
        [
            nicknameLabel,
            nicknameField,
            nicknameButton
        ].forEach { view.addSubview($0) }
        
        nicknameField.delegate = self
        nicknameButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    override func setLayout() {
        nicknameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(276)
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

    @objc private func saveButtonTapped() {
        guard let nickname = nicknameField.text, !nickname.isEmpty else {
            return
        }

        RealmManager.shared.saveNickname(nickname)

        showSaveAlert(nickname: nickname)
    }

    private func loadNickname() {
        if let savedNickname = RealmManager.shared.getUser()?.nickname {
            nicknameField.text = savedNickname
            updateNicknameButtonState(isEnabled: true, backgroundColor: .FDE_1_AD, textColor: .A_98_E_5_C)
            print("✅ 저장된 닉네임 불러오기: \(savedNickname ?? "")")
        }
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

    func updateNicknameButtonState(isEnabled: Bool, backgroundColor: UIColor, textColor: UIColor) {
        nicknameButton.isEnabled = isEnabled
        nicknameButton.backgroundColor = backgroundColor
        nicknameButton.setTitleColor(textColor, for: .normal)
    }
}
