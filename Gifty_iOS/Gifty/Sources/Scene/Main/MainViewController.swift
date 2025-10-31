import UIKit
import SnapKit
import Then
import RealmSwift
import Realm

class MainViewController: BaseViewController {
    
    private let iconImageView = UIImageView().then {
        $0.image = UIImage(named: "GiftyBox")
    }

    private let titleLabel = UILabel().then {
        $0.text = ""
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .nicknameFont(size: 15)
    }
    
    private let sortButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "arrowDown")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.baseForegroundColor = ._6_A_4_C_4_C
        $0.configuration = config
        $0.addTarget(self, action: #selector(toggleSortDropdown), for: .touchUpInside)
    }
    
    private let sortDropDownView = SortDropDownView().then {
        $0.isHidden = true
    }

    private let noneLabel = UILabel().then {
        $0.text = "아직 등록된 교환권이 없어요"
        $0.textColor = ._7_F_7_D_7_D
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .giftyFont(size: 28)
    }

    private let boxImageView = UIImageView().then {
        $0.image = UIImage(named: "EmptyBox")
    }

    private let gifticonTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(GifticonTableViewCell.self, forCellReuseIdentifier: GifticonTableViewCell.identifier)
    }
    
    private let testNotificationButton = UIButton(type: .system).then {
        $0.setTitle("Test Notification", for: .normal)
        $0.addTarget(self, action: #selector(testNotificationButtonTapped), for: .touchUpInside)
    }

    private var gifts: Results<Gift>?
    private var notificationToken: NotificationToken?
    private var currentSortOrder: SortOrder = .byRegistrationDate
    
    var ShowCheckModal = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifticonTableView.dataSource = self
        gifticonTableView.delegate = self
        sortDropDownView.delegate = self
        
        setupTitleLabel()
        updateSortButtonTitle()
        loadGifts()
        setupRealmNotification()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeepLink(_:)),
            name: NSNotification.Name("OpenGifticon"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshGiftList),
            name: NSNotification.Name("RefreshGiftList"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gifticonTableView.reloadData()
        
        if ShowCheckModal {
            ShowCheckModal = false
            let checkModalVC = CheckModalViewController()
            checkModalVC.modalPresentationStyle = .overFullScreen
            present(checkModalVC, animated: false)
        }
    }
    
    @MainActor
    deinit {
        notificationToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func addView() {
        [
            iconImageView,
            titleLabel,
            sortButton,
            sortDropDownView,
            boxImageView,
            noneLabel,
            testNotificationButton,

            gifticonTableView
        ].forEach { view.addSubview($0) }
        
        view.bringSubviewToFront(testNotificationButton)
    }

    override func setLayout() {
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(64)
            $0.leading.equalToSuperview().inset(34)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
        }
        
        sortButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().inset(33)
        }
        
//        testNotificationButton.snp.makeConstraints {
//            $0.bottom.equalTo(sortButton.snp.top).offset(-10)
//            $0.trailing.equalToSuperview().inset(33)
//        }
        
        sortDropDownView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(8)
            $0.trailing.equalTo(sortButton.snp.trailing)
        }

        gifticonTableView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }

        noneLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(281)
        }

        boxImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(noneLabel.snp.top).offset(-49)
            $0.width.equalTo(124.11)
            $0.height.equalTo(113)
        }
    }
    
    private func setupTitleLabel() {
        if let nickname = RealmManager.shared.getUser()?.nickname {
            titleLabel.text = "\(nickname)님의 교환권"
        } else {
            titleLabel.text = "Gifty님의 교환권"
        }
    }
    
    private func loadGifts() {
        gifts = RealmManager.shared.getGifts(sortedBy: currentSortOrder)
        updateUI()
        gifticonTableView.reloadData()
    }
    
    private func setupRealmNotification() {
        notificationToken = gifts?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
            case .initial, .update:
                self.updateUI()
                self.gifticonTableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    private func updateUI() {
        let hasGifts = !(gifts?.isEmpty ?? true)
        gifticonTableView.isHidden = !hasGifts
        noneLabel.isHidden = hasGifts
        boxImageView.isHidden = hasGifts
        sortButton.isHidden = !hasGifts
    }
    
    private func updateSortButtonTitle() {
        let title = currentSortOrder == .byExpiryDate ? "짧은 유효기간 순" : "최신 등록 순"
        var attText = AttributedString(title)
        attText.font = .giftyFont(size: 16)
        sortButton.configuration?.attributedTitle = attText
    }
    
    @objc private func toggleSortDropdown() {
        sortDropDownView.isHidden.toggle()
        if !sortDropDownView.isHidden {
            view.bringSubviewToFront(sortDropDownView)
        }
    }
    
    @objc private func testNotificationButtonTapped() {
        NotificationManager.shared.scheduleDailySummaryNotificationForTest()
    }

    @objc private func refreshGiftList() {
        print("♻️ 기프티콘 목록 새로고침")
        loadGifts()
    }
    
    @objc private func handleDeepLink(_ notification: Notification) {
        guard let giftId = notification.userInfo?["giftId"] as? String else { return }
        
        print("===== MainViewController 딥링크 처리 =====")
        print("기프티콘 ID: \(giftId)")
        
        if let gift = RealmManager.shared.getGift(by: giftId) {
            print("✅ 기프티콘 발견: \(gift.name)")
            print("=====================================")

            let gifticonVC = GifticonViewController()
            gifticonVC.gift = gift

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.navigationController?.pushViewController(gifticonVC, animated: true)
            }
        } else {
            print("❌ 기프티콘을 찾을 수 없음")
            print("=====================================")

            let alert = UIAlertController(
                title: "기프티콘 없음",
                message: "해당 기프티콘을 찾을 수 없습니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true)
            }
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gifts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GifticonTableViewCell.identifier, for: indexPath) as? GifticonTableViewCell,
              let gift = gifts?[indexPath.row] else {
            return UITableViewCell()
        }
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        let image = UIImage(contentsOfFile: fileURL.path)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: gift.expiryDate)

        let isExpired = gift.checkIsExpired
        
        cell.configure(image: image, title: gift.name, usage: gift.usage, date: dateString, isExpired: isExpired)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let gift = gifts?[indexPath.row] else { return }
        
        let gifticonVC = GifticonViewController()
        gifticonVC.gift = gift
        navigationController?.pushViewController(gifticonVC, animated: true)
    }
}

extension MainViewController: SortDropDownViewDelegate {
    func sortButtonTapped(sortOrder: SortOrder) {
        currentSortOrder = sortOrder
        sortDropDownView.set(sortOrder: sortOrder)
        sortDropDownView.isHidden = true
        updateSortButtonTitle()
        loadGifts()
    }
}
