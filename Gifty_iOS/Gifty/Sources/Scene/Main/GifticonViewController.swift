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
        $0.contentMode = .scaleAspectFill
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
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let storeLabel = UILabel().then {
        $0.text = "사용처"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }

    private let storecontentLabel = UILabel().then {
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let expiryLabel = UILabel().then {
        $0.text = "유효기간"
        $0.font = .giftyFont(size: 22)
        $0.textColor = .CDB_9_AD
    }

    private let expirycontentLabel = UILabel().then {
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
    
    private let productInfoView = UIView()
    private let storeInfoView = UIView()
    private let expiryInfoView = UIView()
    private let memoInfoView = UIView()
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
        let actionSheet = UIAlertController(
            title: "공유 방법 선택",
            message: "어떻게 공유하시겠어요?",
            preferredStyle: .actionSheet
        )

        if ShareApi.isKakaoTalkSharingAvailable() {
            actionSheet.addAction(UIAlertAction(
                title: "💬 카카오톡으로 공유",
                style: .default,
                handler: { [weak self] _ in
                    self?.shareToKakaoTalk()
                }
            ))
        }

        actionSheet.addAction(UIAlertAction(
            title: "📷 이미지로 공유",
            style: .default,
            handler: { [weak self] _ in
                self?.shareImage()
            }
        ))

        actionSheet.addAction(UIAlertAction(
            title: "취소",
            style: .cancel
        ))

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }
        
        present(actionSheet, animated: true)
    }
    
    private func shareToKakaoTalk() {
        guard let gift = gift else { return }
        
        let loadingAlert = UIAlertController(title: nil, message: "공유 준비 중...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)

        SupabaseManager.shared.shareGift(gift) { [weak self] result in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let sharedGiftId):
                        self?.sendKakaoTalkMessage(gift: gift, sharedGiftId: sharedGiftId)
                        
                    case .failure(let error):
                        print("❌ Firebase 업로드 실패: \(error.localizedDescription)")
                        self?.showAlert(title: "공유 실패", message: "기프티콘 공유 중 오류가 발생했습니다.\n\(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func sendKakaoTalkMessage(gift: Gift, sharedGiftId: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let expiryString = dateFormatter.string(from: gift.expiryDate)

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        guard let image = UIImage(contentsOfFile: fileURL.path) else { return }

        let feedTemplate = FeedTemplate(
            content: Content(
                title: "🎁 \(gift.name)",
                imageUrl: URL(string: "https://via.placeholder.com/400x300")!,
                description: "\(gift.usage)에서 사용 가능\n유효기간: \(expiryString)까지\n\n아래 버튼을 눌러 받아가세요!",
                link: Link(
                    webUrl: URL(string: "https://gifty.app"),
                    mobileWebUrl: URL(string: "https://gifty.app")
                )
            ),
            buttons: [
                Button(
                    title: "기프티콘 받기",
                    link: Link(
                        iosExecutionParams: ["path": "gift", "id": sharedGiftId]
                    )
                )
            ]
        )

        if ShareApi.isKakaoTalkSharingAvailable() {
            print("===== 카카오톡 공유 시작 =====")
            print("공유 ID: \(sharedGiftId)")
            ShareApi.shared.shareDefault(templatable: feedTemplate) { [weak self] (sharingResult, error) in
                if let error = error {
                    print("❌ 카카오톡 공유 실패: \(error.localizedDescription)")
                    print("에러 상세: \(error)")
                    print("============================")
                    self?.showKakaoShareError()
                } else {
                    print("✅ 카카오톡 공유 성공")
                    print("============================")

                    RealmManager.shared.updateGiftSharedStatus(gift, isShared: true)
                    self?.configure(with: gift)

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

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        if let gift = gift {
            configure(with: gift)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(deleteButton)
        view.bringSubviewToFront(shareButton)
        view.bringSubviewToFront(modifyButton)
        view.bringSubviewToFront(exitButton)
    }

    override func addView() {
        [contentView, shadowView].forEach { view.addSubview($0) }
        shadowView.addSubview(imageView)

        [exitButton, deleteButton, shareButton, modifyButton].forEach { view.addSubview($0) }
        
        productInfoView.addSubview(productLabel)
        productInfoView.addSubview(productcontentLabel)
        storeInfoView.addSubview(storeLabel)
        storeInfoView.addSubview(storecontentLabel)
        expiryInfoView.addSubview(expiryLabel)
        expiryInfoView.addSubview(expirycontentLabel)
        memoInfoView.addSubview(memoLabel)
        memoInfoView.addSubview(memocontentLabel)
        
        [productInfoView, storeInfoView, expiryInfoView, memoInfoView].forEach { contentView.addSubview($0) }
        
    }

    private func configure(with gift: Gift) {
        productcontentLabel.text = gift.name
        storecontentLabel.text = gift.usage

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        expirycontentLabel.text = dateFormatter.string(from: gift.expiryDate)

        let isMemoEmpty = gift.memo?.isEmpty ?? true
        memocontentLabel.text = isMemoEmpty ? "등록된 메모가 없어요" : gift.memo
        memocontentLabel.textColor = isMemoEmpty ? .CDB_9_AD : ._6_A_4_C_4_C

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        if let originalImage = UIImage(contentsOfFile: fileURL.path) {
            if gift.isShared {
                imageView.image = applyBlurAndLogo(to: originalImage)
            } else {
                imageView.image = originalImage
            }
        }
    }

    private func applyBlurAndLogo(to image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return image }

        image.draw(at: .zero)

        context.saveGState()
        let blurredImage = image.applyGaussianBlur(radius: 10)
        blurredImage?.draw(at: .zero, blendMode: .normal, alpha: 0.9)
        context.restoreGState()

        if let logoImage = UIImage(named: "GiftyBox") {
            let logoSize = CGSize(width: image.size.width * 0.3, height: image.size.height * 0.3)
            let logoOrigin = CGPoint(
                x: (image.size.width - logoSize.width) / 2,
                y: (image.size.height - logoSize.height) / 2
            )
            logoImage.draw(in: CGRect(origin: logoOrigin, size: logoSize), blendMode: .normal, alpha: 0.8)
        }

        return UIGraphicsGetImageFromCurrentImageContext()
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
        productInfoView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
        }
        storeLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        storecontentLabel.snp.makeConstraints {
            $0.leading.equalTo(storeLabel.snp.trailing).offset(42)
            $0.top.bottom.trailing.equalToSuperview()
        }
        storeInfoView.snp.makeConstraints {
            $0.top.equalTo(productInfoView.snp.bottom).offset(14)
        }
        expiryLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        expirycontentLabel.snp.makeConstraints {
            $0.leading.equalTo(expiryLabel.snp.trailing).offset(30)
            $0.top.bottom.trailing.equalToSuperview()
        }
        expiryInfoView.snp.makeConstraints {
            $0.top.equalTo(storeInfoView.snp.bottom).offset(14)
        }
        memoLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        memocontentLabel.snp.makeConstraints {
            $0.leading.equalTo(memoLabel.snp.trailing).offset(55)
            $0.top.bottom.trailing.equalToSuperview()
        }
        memoInfoView.snp.makeConstraints {
            $0.top.equalTo(expiryInfoView.snp.bottom).offset(14)
        }
        contentView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(shadowView.snp.bottom).offset(40)
            $0.width.equalTo(245)
            $0.height.equalTo(234)
        }
        shareButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.trailing.equalTo(modifyButton.snp.leading).offset(-10)
            $0.bottom.equalTo(shadowView.snp.top).offset(-11)
        }
        deleteButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.trailing.equalTo(shareButton.snp.leading).offset(-10)
            $0.bottom.equalTo(shadowView.snp.top).offset(-11)
        }
        modifyButton.snp.makeConstraints {
            $0.width.equalTo(68)
            $0.height.equalTo(33)
            $0.trailing.equalTo(shadowView.snp.trailing)
            $0.centerY.equalTo(shareButton)
        }
        exitButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.top.equalTo(view.snp.top).offset(74)
            $0.leading.equalToSuperview().inset(20)
        }
        
    }

    @objc private func imageViewTapped() {
        guard let gift = gift else { return }

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        guard let originalImage = UIImage(contentsOfFile: fileURL.path) else { return }

        let displayImage: UIImage?
        if gift.isShared {
            displayImage = applyBlurAndLogo(to: originalImage)
        } else {
            displayImage = originalImage
        }

        let zoomVC = ImageZoomViewController()
        zoomVC.image = displayImage
        zoomVC.modalPresentationStyle = .fullScreen
        present(zoomVC, animated: true, completion: nil)
    }

    @objc
    private func deleteButtonTapped() {
        let deleteModalVC = DeleteModalViewController()
        deleteModalVC.modalPresentationStyle = .overFullScreen
        deleteModalVC.modalTransitionStyle = .crossDissolve
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

extension GifticonViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
