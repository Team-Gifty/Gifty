import UIKit
import SnapKit
import Then
import RealmSwift
import Realm

class ArchiveViewController: BaseViewController {

    private let titleLabel = UILabel().then {
        $0.text = "💝 간직함"
        $0.font = .giftyFont(size: 28)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let noneLabel = UILabel().then {
        $0.text = "간직한 교환권이 없어요"
        $0.textColor = ._7_F_7_D_7_D
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .giftyFont(size: 24)
    }

    private let archiveTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(ArchiveTableViewCell.self, forCellReuseIdentifier: ArchiveTableViewCell.identifier)
    }

    private var archivedGifts: Results<Gift>?
    private var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        archiveTableView.dataSource = self
        archiveTableView.delegate = self
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        loadArchivedGifts()
        setupRealmNotification()
    }

    @MainActor
    deinit {
        notificationToken?.invalidate()
    }

    override func addView() {
        [titleLabel, backButton, noneLabel, archiveTableView].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }

        archiveTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        noneLabel.snp.makeConstraints {
            $0.center.equalTo(archiveTableView)
        }
    }

    private func loadArchivedGifts() {
        archivedGifts = RealmManager.shared.realm.objects(Gift.self)
            .filter("isArchived == true")
            .sorted(byKeyPath: "id", ascending: false)
        updateUI()
        archiveTableView.reloadData()
    }

    private func setupRealmNotification() {
        notificationToken = archivedGifts?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
            case .initial, .update:
                self.updateUI()
                self.archiveTableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }

    private func updateUI() {
        let hasGifts = !(archivedGifts?.isEmpty ?? true)
        archiveTableView.isHidden = !hasGifts
        noneLabel.isHidden = hasGifts
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension ArchiveViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedGifts?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArchiveTableViewCell.identifier, for: indexPath) as? ArchiveTableViewCell,
              let gift = archivedGifts?[indexPath.row] else {
            return UITableViewCell()
        }

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        let image = UIImage(contentsOfFile: fileURL.path)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: gift.expiryDate)

        cell.configure(image: image, title: gift.name, giverName: gift.giverName, date: dateString)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let gift = archivedGifts?[indexPath.row] else { return }

        let gifticonVC = GifticonViewController()
        gifticonVC.gift = gift
        navigationController?.pushViewController(gifticonVC, animated: true)
    }
}
