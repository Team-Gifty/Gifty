import UIKit
import SnapKit
import Then

class ArchiveTableViewCell: UITableViewCell {

    static let identifier = "ArchiveTableViewCell"

    private let shadowView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 12
        $0.layer.masksToBounds = false
    }

    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1.0)
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }

    private let imageContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.08
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
    }

    private let gifticonImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .lightGray
    }

    private let heartIcon = UILabel().then {
        $0.text = "💝"
        $0.font = .systemFont(ofSize: 20)
    }

    private let titleLabel = UILabel().then {
        $0.font = .giftyFont(size: 15)
        $0.textColor = ._6_A_4_C_4_C
        $0.text = "제목"
        $0.numberOfLines = 2
    }

    private let fromContainer = UIView().then {
        $0.backgroundColor = UIColor.CBBDB_1.withAlphaComponent(0.2)
        $0.layer.cornerRadius = 8
    }

    private let fromLabel = UILabel().then {
        $0.text = "From"
        $0.font = .giftyFont(size: 10)
        $0.textColor = .CDB_9_AD
    }

    private let giverLabel = UILabel().then {
        $0.font = .giftyFont(size: 12)
        $0.textColor = ._6_A_4_C_4_C
        $0.text = "준 사람"
    }

    private let dateIcon = UILabel().then {
        $0.text = "📅"
        $0.font = .systemFont(ofSize: 11)
    }

    private let dateLabel = UILabel().then {
        $0.font = .giftyFont(size: 11)
        $0.textColor = .CDB_9_AD
        $0.text = "YYYY.MM.DD"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear

        addView()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func addView() {
        contentView.addSubview(shadowView)
        contentView.addSubview(containerView)

        containerView.addSubview(imageContainerView)
        imageContainerView.addSubview(gifticonImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(heartIcon)
        containerView.addSubview(fromContainer)
        fromContainer.addSubview(fromLabel)
        fromContainer.addSubview(giverLabel)
        containerView.addSubview(dateIcon)
        containerView.addSubview(dateLabel)
    }

    private func setLayout() {
        shadowView.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview().inset(8)
        }

        imageContainerView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.width.height.equalTo(100)
        }

        gifticonImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        heartIcon.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(imageContainerView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(45)
        }

        fromContainer.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.height.equalTo(28)
        }

        fromLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }

        giverLabel.snp.makeConstraints {
            $0.leading.equalTo(fromLabel.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }

        dateIcon.snp.makeConstraints {
            $0.leading.equalTo(imageContainerView)
            $0.bottom.equalToSuperview().inset(16)
        }

        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(dateIcon.snp.trailing).offset(6)
            $0.centerY.equalTo(dateIcon)
        }
    }

    func configure(image: UIImage?, title: String, giverName: String?, date: String) {
        gifticonImageView.image = image
        titleLabel.text = title
        giverLabel.text = giverName ?? "알 수 없음"
        dateLabel.text = date
    }
}
