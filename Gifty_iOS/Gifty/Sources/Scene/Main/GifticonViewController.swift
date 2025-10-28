import UIKit
import SnapKit
import Then
import KakaoSDKShare
import KakaoSDKTemplate
import Realm

class GifticonViewController: BaseViewController {
    var gift: Gift?

    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "Test")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.isUserInteractionEnabled = true
    }

    private let shadowView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 15
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 1
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    private let productLabel = UILabel().then {
        $0.text = "상품명"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }

    private let productcontentLabel = UILabel().then {
        $0.text = "상품명 내용"
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let storeLabel = UILabel().then {
        $0.text = "사용처"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }

    private let storecontentLabel = UILabel().then {
        $0.text = "사용처 내용"
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let expiryLabel = UILabel().then {
        $0.text = "유효기간"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }

    private let expirycontentLabel = UILabel().then {
        $0.text = "유효기간 내용"
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let memoLabel = UILabel().then {
        $0.text = "메모"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }

    private let memocontentLabel = UILabel().then {
        $0.text = "등록된 메모가 없어요"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }
    
    private let pView = UIView()
    private let sView = UIView()
    private let eView = UIView()
    private let mView = UIView()
    private let contentView = UIView()

    private let modifyButton = UIButton().then {
        $0.setImage(UIImage(named: "Modify"), for: .normal)
        $0.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
    }

    private  let shareButton = UIButton().then {
        $0.setImage(UIImage(named: "Share"), for: .normal)
        $0.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }

    @objc private func shareButtonTapped() {
        // 공유 옵션 선택 액션시트
        let actionSheet = UIAlertController(
            title: "공유 방법 선택",
            message: "어떻게 공유하시겠어요?",
            preferredStyle: .actionSheet
        )
        
        // 카카오톡 공유
        if ShareApi.isKakaoTalkSharingAvailable() {
            actionSheet.addAction(UIAlertAction(
                title: "💬 카카오톡으로 공유",
                style: .default,
                handler: { [weak self] _ in
                    self?.shareToKakaoTalk()
                }
            ))
        }
        
        // 이미지 공유
        actionSheet.addAction(UIAlertAction(
            title: "📷 이미지로 공유",
            style: .default,
            handler: { [weak self] _ in
                self?.shareImage()
            }
        ))
        
        // 취소
        actionSheet.addAction(UIAlertAction(
            title: "취소",
            style: .cancel
        ))
        
        // iPad 지원
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }
        
        present(actionSheet, animated: true)
    }
    
    private func shareToKakaoTalk() {
        guard let gift = gift else { return }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let expiryString = dateFormatter.string(from: gift.expiryDate)
        
        
        let feedTemplate = FeedTemplate(
            content: Content(
                title: "🎁 \(gift.name)",
                imageUrl: URL(string: "https://via.placeholder.com/400x300")!, // 임시 이미지
                description: "사용처: \(gift.usage)\n유효기간: \(expiryString)",
                link: Link(
                    webUrl: URL(string: "https://gifty.app"),
                    mobileWebUrl: URL(string: "https://gifty.app")
                )
            ),
            buttons: [
                Button(
                    title: "앱에서 보기",
                    link: Link(
                        webUrl: URL(string: "https://gifty.app"),
                        mobileWebUrl: URL(string: "gifty://gifticon?id=\(gift.id.stringValue)"),
                        iosExecutionParams: ["id": gift.id.stringValue]
                    )
                )
            ]
        )

        if ShareApi.isKakaoTalkSharingAvailable() {
            print("===== 카카오톡 공유 시작 =====")
            ShareApi.shared.shareDefault(templatable: feedTemplate) { [weak self] (sharingResult, error) in
                if let error = error {
                    print("❌ 카카오톡 공유 실패: \(error.localizedDescription)")
                    print("에러 상세: \(error)")
                    print("============================")
                    self?.showKakaoShareError()
                } else {
                    print("✅ 카카오톡 공유 성공")
                    print("============================")
                    if let sharingResult = sharingResult {
                        UIApplication.shared.open(sharingResult.url, options: [:])
                    }
                }
            }
        } else {
            print("⚠️ 카카오톡이 설치되지 않음")
            showAlert(title: "카카오톡 없음", message: "카카오톡이 설치되지 않았습니다.")
        }
    }

    private func shareImage() {
        guard let image = imageView.image else {
            showAlert(title: "오류", message: "공유할 이미지가 없습니다.")
            return
        }
        
        print("===== 이미지 공유 시작 =====")
        
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // iPad 지원
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }
        
        present(activityViewController, animated: true)
    }

    private func showKakaoShareError() {
        let alert = UIAlertController(
            title: "공유 실패",
            message: "카카오톡 공유 중 오류가 발생했습니다.\n이미지로 공유하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "이미지 공유", style: .default) { [weak self] _ in
            self?.shareImage()
        })
        present(alert, animated: true)
    }
    
    // 일반 알림
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private  let deleteButton = UIButton().then {
        $0.setImage(UIImage(named: "Delete"), for: .normal)
        $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    private let exitButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
        $0.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        if let gift = gift {
            configure(with: gift)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
    }

    override func addView() {
        [contentView, shadowView].forEach { view.addSubview($0) }
        shadowView.addSubview(imageView)

        [exitButton, deleteButton, shareButton, modifyButton].forEach { view.addSubview($0) }
        
        pView.addSubview(productLabel)
        pView.addSubview(productcontentLabel)
        sView.addSubview(storeLabel)
        sView.addSubview(storecontentLabel)
        eView.addSubview(expiryLabel)
        eView.addSubview(expirycontentLabel)
        mView.addSubview(memoLabel)
        mView.addSubview(memocontentLabel)
        
        [pView, sView, eView, mView].forEach { contentView.addSubview($0) }
    }

    private func configure(with gift: Gift) {
        productcontentLabel.text = gift.name
        storecontentLabel.text = gift.usage

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        expirycontentLabel.text = dateFormatter.string(from: gift.expiryDate)

        memocontentLabel.text = gift.memo ?? "등록된 메모가 없어요"
        memocontentLabel.textColor = gift.memo == nil ? .CDB_9_AD : ._6_A_4_C_4_C

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        imageView.image = UIImage(contentsOfFile: fileURL.path)
    }

    @objc private func exitButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    override func setLayout() {
        shadowView.snp.makeConstraints {
            $0.width.equalTo(287)
            $0.height.equalTo(323)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(118)
        }
        imageView.snp.makeConstraints {
            $0.width.equalTo(287)
            $0.height.equalTo(323)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(118)
        }
        productLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        productcontentLabel.snp.makeConstraints {
            $0.leading.equalTo(productLabel.snp.trailing).offset(42)
            $0.top.bottom.trailing.equalToSuperview()
        }
        pView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
        }
        storeLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        storecontentLabel.snp.makeConstraints {
            $0.leading.equalTo(storeLabel.snp.trailing).offset(42)
            $0.top.bottom.trailing.equalToSuperview()
        }
        sView.snp.makeConstraints {
            $0.top.equalTo(pView.snp.bottom).offset(14)
        }
        expiryLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        expirycontentLabel.snp.makeConstraints {
            $0.leading.equalTo(expiryLabel.snp.trailing).offset(30)
            $0.top.bottom.trailing.equalToSuperview()
        }
        eView.snp.makeConstraints {
            $0.top.equalTo(sView.snp.bottom).offset(14)
        }
        memoLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        memocontentLabel.snp.makeConstraints {
            $0.leading.equalTo(memoLabel.snp.trailing).offset(55)
            $0.top.bottom.trailing.equalToSuperview()
        }
        mView.snp.makeConstraints {
            $0.top.equalTo(eView.snp.bottom).offset(14)
        }
        contentView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(shadowView.snp.bottom).offset(40)
            $0.width.equalTo(245)
            $0.height.equalTo(234)
        }
        modifyButton.snp.makeConstraints {
            $0.trailing.equalTo(shadowView.snp.trailing)
            $0.bottom.equalTo(shadowView.snp.top).offset(-11)
        }
        shareButton.snp.makeConstraints {
            $0.trailing.equalTo(modifyButton.snp.leading).offset(-10)
            $0.bottom.equalTo(shadowView.snp.top).offset(-11)
        }
        deleteButton.snp.makeConstraints {
            $0.trailing.equalTo(shareButton.snp.leading).offset(-10)
            $0.bottom.equalTo(shadowView.snp.top).offset(-11)
        }
        exitButton.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(74)
            $0.leading.equalToSuperview().inset(34)
        }
        
    }

    @objc private func imageViewTapped() {
        let zoomVC = ImageZoomViewController()
        zoomVC.image = imageView.image
        zoomVC.modalPresentationStyle = .fullScreen
        present(zoomVC, animated: true, completion: nil)
    }

    @objc
    private func deleteButtonTapped() {
        let deleteModalVC = DeleteModalViewController()
        deleteModalVC.modalPresentationStyle = .overFullScreen
        deleteModalVC.onDelete = {
            if let gift = self.gift {
                RealmManager.shared.deleteGift(gift)
                NotificationManager.shared.scheduleDailySummaryNotification()
                self.navigationController?.popViewController(animated: true)
            }
        }
        self.present(deleteModalVC, animated: true, completion: nil)
    }
    
    @objc private func modifyButtonTapped() {
        let modifyVC = ModifyGiftViewController()
        modifyVC.gift = self.gift
        modifyVC.delegate = self
        self.present(modifyVC, animated: true, completion: nil)
    }
}

extension GifticonViewController: ModifyGiftViewControllerDelegate {
    func didModifyGiftInfo(name: String, usage: String, expiryDate: Date, memo: String?) {
        if let gift = self.gift {
            RealmManager.shared.updateGift(gift, name: name, usage: usage, expiryDate: expiryDate, memo: memo)
            configure(with: gift)
            NotificationManager.shared.scheduleDailySummaryNotification()
        }
    }
}
