import UIKit
import SnapKit
import Then

class ArchiveTableViewCell: UITableViewCell {

    static let identifier = "ArchiveTableViewCell"

    private let shadowView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor(named: "595959")?.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowOffset = CGSize(width: 1, height: 2.5)
        $0.layer.shadowRadius = 2
        $0.layer.masksToBounds = false
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .FFFEF_7
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    private let gifticonImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .lightGray
    }

    private let titleLabel = UILabel().then {
        $0.font = .cellFont(size: 11)
        $0.textColor = UIColor(named: "6A4C4C")
        $0.text = "제목"
    }

    private let giverLabel = UILabel().then {
        $0.font = .cellFont(size: 9)
        $0.textColor = UIColor(named: "6A4C4C")
        $0.text = "준 사람"
    }

    private let dateLabel = UILabel().then {
        $0.font = .cellFont(size: 12)
        $0.textColor = UIColor(named: "6A4C4C")
        $0.text = "YYYY.MM.DD"
    }

    private let archiveBadge = UIView().then {
        $0.backgroundColor = .CBBDB_1
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    private let archiveLabel = UILabel().then {
        $0.text = "💝 간직함"
        $0.font = .cellFont(size: 9)
        $0.textColor = ._6_A_4_C_4_C
        $0.textAlignment = .center
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

        containerView.addSubview(gifticonImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(giverLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(archiveBadge)
        archiveBadge.addSubview(archiveLabel)
    }

    private func setLayout() {
        shadowView.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }

        containerView.snp.makeConstraints {
            $0.width.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(89)
            $0.center.equalToSuperview()
        }

        gifticonImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(13)
            $0.width.height.equalTo(73.3)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(gifticonImageView.snp.top).offset(4)
            $0.leading.equalTo(gifticonImageView.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(-12)
        }

        giverLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(11)
            $0.leading.equalTo(titleLabel.snp.leading)
        }

        archiveBadge.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(giverLabel.snp.bottom).offset(6)
            $0.height.equalTo(20)
        }

        archiveLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview().inset(3)
        }

        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.bottom.equalToSuperview().offset(-9)
        }
    }

    func configure(image: UIImage?, title: String, giverName: String?, date: String) {
        gifticonImageView.image = image
        titleLabel.text = title
        giverLabel.text = giverName ?? "알 수 없음"
        dateLabel.text = date
    }
}
