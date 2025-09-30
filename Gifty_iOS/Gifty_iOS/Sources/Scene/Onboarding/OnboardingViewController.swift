import UIKit
import SnapKit
import Then

class OnboardingViewController: BaseViewController {
    
    private let viewModel = OnboardingViewModel()
    
    let onboardingButton = GiftyButton(
        buttonText: "Gifty 사용하러 가기",
        isEnabled: true,
        height: 50
    )
    
    let onboardingImage = UIImageView(image: UIImage(named: "Phone"))
    
    let onboardingLabel = UILabel().then {
        $0.text = "소중한 선물, 놓치지 않도록\nGifty가 도와드려요"
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .onboardingFont(size: 30)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        onboardingButton.addTarget(self, action: #selector(onboardingButtonDidTap), for: .touchUpInside)
        onboardingButton.addTarget(self, action: #selector(goNickname), for: .touchUpInside)
        
        self.navigationController?.navigationBar.isHidden = true
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
    
    func setupGiftyButtonStyle() {
        onboardingButton.isEnabled = true
        onboardingButton.backgroundColor = UIColor(named: "FDE1AD") ?? .systemBrown
        onboardingButton.setTitleColor(.A_98_E_5_C, for: .normal)
    }
    
    
    @objc func goNickname() {
        let NicknameVC = NicknameViewController()
        self.navigationController?.pushViewController(NicknameVC, animated: true)
    }


//    @objc func onboardingButtonDidTap() {
//      //  viewModel.onboardingButtonDidTap
//    }
    
    
}
