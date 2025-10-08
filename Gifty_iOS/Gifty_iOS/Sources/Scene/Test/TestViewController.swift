import UIKit
import SnapKit
import Then
import RealmSwift

class TestViewController: BaseViewController {
    
    let titleLabel = UILabel().then {
        $0.text = "Realm 테스트"
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textAlignment = .center
    }
    
    let nicknameLabel = UILabel().then {
        $0.text = "저장된 닉네임: -"
        $0.font = .systemFont(ofSize: 18)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    let loadButton = UIButton().then {
        $0.setTitle("닉네임 불러오기", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle("닉네임 삭제", for: .normal)
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    let addGifticonButton = UIButton().then {
        $0.setTitle("임시 교환권 추가", for: .normal)
        $0.backgroundColor = .systemGreen
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNickname()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override func addView() {
        [
            titleLabel,
            nicknameLabel,
            loadButton,
            deleteButton,
            addGifticonButton
        ].forEach { view.addSubview($0) }
        
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        addGifticonButton.addTarget(self, action: #selector(addGifticonButtonTapped), for: .touchUpInside)
    }
    
    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.centerX.equalToSuperview()
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        loadButton.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(50)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(loadButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(50)
        }
        
        addGifticonButton.snp.makeConstraints {
            $0.top.equalTo(deleteButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(50)
        }
    }
    
    @objc private func loadButtonTapped() {
        loadNickname()
    }
    
    private func loadNickname() {
        if let nickname = RealmManager.shared.getNickname() {
            nicknameLabel.text = "저장된 닉네임: \(nickname)"
            print("✅ 닉네임 불러오기 성공: \(nickname)")
        } else {
            nicknameLabel.text = "저장된 닉네임: 없음"
            print("ℹ️ 저장된 닉네임이 없습니다")
        }
    }
    
    @objc private func deleteButtonTapped() {
        RealmManager.shared.deleteNickname()
        nicknameLabel.text = "저장된 닉네임: 삭제됨"
        
        let alert = UIAlertController(
            title: "삭제 완료",
            message: "닉네임이 삭제되었습니다",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func addGifticonButtonTapped() {
        let image = UIImage(named: "GiftyBox")?.pngData()
        
        let gifticon1 = GifticonModel(gifticonName: "hhh", usage: "스타벅스", expirationDate: Date(timeIntervalSinceNow: 3600 * 24 * 30), imageData: image)
        let gifticon2 = GifticonModel(gifticonName: "투썸플레이스 케이크", usage: "투썸플레이스", expirationDate: Date(timeIntervalSinceNow: 3600 * 24 * 60), imageData: image)
        let gifticon3 = GifticonModel(gifticonName: "BHC 치킨", usage: "BHC", expirationDate: Date(timeIntervalSinceNow: 3600 * 24 * 90), imageData: image)
        
        [gifticon1, gifticon2, gifticon3].forEach {
            RealmManager.shared.saveGifticon(model: $0)
        }
        
        let alert = UIAlertController(
            title: "추가 완료",
            message: "임시 교환권 3개가 추가되었습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
