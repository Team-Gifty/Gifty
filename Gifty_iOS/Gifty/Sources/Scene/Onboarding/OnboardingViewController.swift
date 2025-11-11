import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class OnboardingViewController: BaseViewController {

    private let viewModel = OnboardingViewModel()
    private let disposeBag = DisposeBag()

    let onboardingButton = GiftyButton(
        buttonText: "Gifty 사용하러 가기",
        isEnabled: true,
        height: 50
    )

    let onboardingImage = UIImageView(image: UIImage(named: "MockTest"))

    let onboardingLabel = UILabel().then {
        $0.text = "소중한 선물, 놓치지 않도록\nGifty가 도와드려요"
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .onboardingFont(size: 30)
        $0.textColor = ._6_A_4_C_4_C
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        bind()
    }

    override func addView() {
        [
            onboardingButton,
            onboardingImage,
            onboardingLabel
        ].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        onboardingButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(27)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(7)
        }

        onboardingImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(177)
            $0.width.equalTo(113)
            $0.height.equalTo(176)
        }

        onboardingLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(onboardingImage.snp.bottom).offset(14)
        }
    }

    private func bind() {
        let input = OnboardingViewModel.Input(
            buttonTap: onboardingButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.navigateToNickname
            .subscribe(onNext: { [weak self] in
                self?.goNickname()
            })
            .disposed(by: disposeBag)
    }

    private func goNickname() {
        let nicknameVC = NicknameViewController()
        self.navigationController?.pushViewController(nicknameVC, animated: true)
    }
}
