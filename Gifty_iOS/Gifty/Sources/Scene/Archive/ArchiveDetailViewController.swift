import UIKit
import SnapKit
import Then
import RealmSwift

class ArchiveDetailViewController: BaseViewController {
    var gift: Gift?

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let heartTitleLabel = UILabel().then {
        $0.text = "💝 소중한 추억"
        $0.font = .giftyFont(size: 22)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let imageCardView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 12
    }

    private let gifticonImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .lightGray
        $0.isUserInteractionEnabled = true
    }

    private let infoCardView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1.0)
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.CBBDB_1.withAlphaComponent(0.3).cgColor
    }

    private let giftNameLabel = UILabel().then {
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    private let divider1 = UIView().then {
        $0.backgroundColor = .CBBDB_1.withAlphaComponent(0.3)
    }

    private let fromIconLabel = UILabel().then {
        $0.text = "💌"
        $0.font = .systemFont(ofSize: 20)
    }

    private let fromTitleLabel = UILabel().then {
        $0.text = "From."
        $0.font = .giftyFont(size: 14)
        $0.textColor = .CDB_9_AD
    }

    private let giverNameLabel = UILabel().then {
        $0.font = .giftyFont(size: 18)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let divider2 = UIView().then {
        $0.backgroundColor = .CBBDB_1.withAlphaComponent(0.3)
    }

    private let dateIconLabel = UILabel().then {
        $0.text = "📅"
        $0.font = .systemFont(ofSize: 20)
    }

    private let dateTitleLabel = UILabel().then {
        $0.text = "사용 기한"
        $0.font = .giftyFont(size: 14)
        $0.textColor = .CDB_9_AD
    }

    private let dateLabel = UILabel().then {
        $0.font = .giftyFont(size: 18)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let divider3 = UIView().then {
        $0.backgroundColor = .CBBDB_1.withAlphaComponent(0.3)
    }

    private let storeIconLabel = UILabel().then {
        $0.text = "🏪"
        $0.font = .systemFont(ofSize: 20)
    }

    private let storeTitleLabel = UILabel().then {
        $0.text = "사용처"
        $0.font = .giftyFont(size: 14)
        $0.textColor = .CDB_9_AD
    }

    private let storeLabel = UILabel().then {
        $0.font = .giftyFont(size: 18)
        $0.textColor = ._6_A_4_C_4_C
        $0.numberOfLines = 0
    }

    private let memoCardView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1.0)
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.CBBDB_1.withAlphaComponent(0.3).cgColor
        $0.isHidden = true
    }

    private let memoIconLabel = UILabel().then {
        $0.text = "📝"
        $0.font = .systemFont(ofSize: 20)
    }

    private let memoTitleLabel = UILabel().then {
        $0.text = "추억의 한마디"
        $0.font = .giftyFont(size: 16)
        $0.textColor = .CDB_9_AD
    }

    private let memoLabel = UILabel().then {
        $0.font = .giftyFont(size: 16)
        $0.textColor = ._6_A_4_C_4_C
        $0.numberOfLines = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        if let gift = gift {
            configure(with: gift)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        gifticonImageView.addGestureRecognizer(tapGesture)
    }

    override func addView() {
        view.addSubview(backButton)
        view.addSubview(heartTitleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            imageCardView,
            infoCardView,
            memoCardView
        ].forEach { contentView.addSubview($0) }

        imageCardView.addSubview(gifticonImageView)

        [
            giftNameLabel,
            divider1,
            fromIconLabel,
            fromTitleLabel,
            giverNameLabel,
            divider2,
            dateIconLabel,
            dateTitleLabel,
            dateLabel,
            divider3,
            storeIconLabel,
            storeTitleLabel,
            storeLabel
        ].forEach { infoCardView.addSubview($0) }

        [
            memoIconLabel,
            memoTitleLabel,
            memoLabel
        ].forEach { memoCardView.addSubview($0) }
    }

    override func setLayout() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.width.height.equalTo(44)
        }

        heartTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }

        imageCardView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(280)
        }

        gifticonImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        infoCardView.snp.makeConstraints {
            $0.top.equalTo(imageCardView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        giftNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        divider1.snp.makeConstraints {
            $0.top.equalTo(giftNameLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        fromIconLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(divider1.snp.bottom).offset(16)
        }

        fromTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(fromIconLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(fromIconLabel)
        }

        giverNameLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(fromIconLabel)
        }

        divider2.snp.makeConstraints {
            $0.top.equalTo(fromIconLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        dateIconLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(divider2.snp.bottom).offset(16)
        }

        dateTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(dateIconLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(dateIconLabel)
        }

        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(dateIconLabel)
        }

        divider3.snp.makeConstraints {
            $0.top.equalTo(dateIconLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        storeIconLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(divider3.snp.bottom).offset(16)
        }

        storeTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(storeIconLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(storeIconLabel)
        }

        storeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalTo(storeTitleLabel.snp.trailing).offset(12)
            $0.top.equalTo(divider3.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().inset(20)
        }

        memoCardView.snp.makeConstraints {
            $0.top.equalTo(infoCardView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(40)
        }

        memoIconLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(20)
        }

        memoTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(memoIconLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(memoIconLabel)
        }

        memoLabel.snp.makeConstraints {
            $0.top.equalTo(memoIconLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }

    private func configure(with gift: Gift) {
        giftNameLabel.text = gift.name
        giverNameLabel.text = gift.giverName ?? "알 수 없음"
        storeLabel.text = gift.usage

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = dateFormatter.string(from: gift.expiryDate)

        if let memo = gift.memo, !memo.isEmpty {
            memoLabel.text = memo
            memoCardView.isHidden = false
        }

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        if let image = UIImage(contentsOfFile: fileURL.path) {
            gifticonImageView.image = image
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func imageViewTapped() {
        guard let image = gifticonImageView.image else { return }

        let zoomVC = ImageZoomViewController()
        zoomVC.image = image
        zoomVC.modalPresentationStyle = .fullScreen
        present(zoomVC, animated: true, completion: nil)
    }
}
