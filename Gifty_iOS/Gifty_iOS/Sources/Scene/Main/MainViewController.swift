//import UIKit
//import SnapKit
//import Then
//
//class MainViewController: BaseViewController {
//
//    let iconImageView = UIImageView().then {
//        $0.image = UIImage(named: "GiftyBox")
//    }
//
//    let nameLabel = UILabel().then {
//        $0.text = "Hello, World!"
//        $0.font = .nicknameFont(size: 15)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func addView() {
//        [
//            iconImageView,
//            nameLabel
//        ].forEach { view.addSubview($0) }
//    }
//
//    override func setLayout() {
//        iconImageView.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
//            $0.leading.equalToSuperview().inset(34)
//        }
//    }
//
//
//}


import UIKit
import SnapKit
import Then

class MainViewController: BaseViewController {
    
    private let iconImageView = UIImageView().then {
        $0.image = UIImage(named: "GiftyBox")
        $0.contentMode = .scaleAspectFit
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "Hello, World!"
        $0.font = .nicknameFont(size: 15)
        $0.textColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    // 네비게이션바 세팅
    private func setupNavigationBar() {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, nameLabel])
        stackView.axis = .horizontal // 라벨이 아이콘 옆에 배치
        stackView.alignment = .center //
        stackView.spacing = 8 // 사이 간격
        
        iconImageView.snp.makeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(36)
            
        }
        
        let leftItem = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = leftItem
    }
}

