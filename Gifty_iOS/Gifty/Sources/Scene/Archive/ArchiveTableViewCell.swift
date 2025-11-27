import UIKit
import SnapKit
import Then

class ArchiveTableViewCell: UITableViewCell {

    static let identifier = "ArchiveTableViewCell"

    private let shadowView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowOffset = CGSize(width: 0, height: 3)
        $0.layer.shadowRadius = 10
        $0.layer.masksToBounds = false
    }

    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.996, green: 0.988, blue: 0.973, alpha: 1.0)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = false
    }

    private let stampView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.CBBDB_1.cgColor
        $0.layer.cornerRadius = 4
        $0.transform = CGAffineTransform(rotationAngle: .pi / 12)
    }

    private let stampIcon = UILabel().then {
        $0.text = "💝"
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .center
    }

    private let envelopeTopView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.89, green: 0.82, blue: 0.75, alpha: 0.3)
    }

    private let letterPaperView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 6
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.05
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowRadius = 2
    }

    private let gifticonImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .lightGray
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.CBBDB_1.withAlphaComponent(0.2).cgColor
    }

    private let polaroidFrame = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 3
        $0.transform = CGAffineTransform(rotationAngle: -.pi / 36)
    }

    private let titleLabel = UILabel().then {
        $0.font = .giftyFont(size: 16)
        $0.textColor = ._6_A_4_C_4_C
        $0.text = "제목"
        $0.numberOfLines = 2
    }

    private let decorLine = UIView().then {
        $0.backgroundColor = .CBBDB_1.withAlphaComponent(0.4)
    }

    private let fromIcon = UILabel().then {
        $0.text = "✉️"
        $0.font = .systemFont(ofSize: 14)
    }

    private let fromLabel = UILabel().then {
        $0.text = "From."
        $0.font = .giftyFont(size: 11)
        $0.textColor = .CDB_9_AD
    }

    private let giverLabel = UILabel().then {
        $0.font = .giftyFont(size: 13)
        $0.textColor = ._6_A_4_C_4_C
        $0.text = "준 사람"
    }

    private let dateLabel = UILabel().then {
        $0.font = .giftyFont(size: 10)
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

        containerView.addSubview(envelopeTopView)
        containerView.addSubview(stampView)
        stampView.addSubview(stampIcon)

        containerView.addSubview(letterPaperView)
        letterPaperView.addSubview(polaroidFrame)
        polaroidFrame.addSubview(gifticonImageView)
        letterPaperView.addSubview(titleLabel)
        letterPaperView.addSubview(decorLine)
        letterPaperView.addSubview(fromIcon)
        letterPaperView.addSubview(fromLabel)
        letterPaperView.addSubview(giverLabel)
        letterPaperView.addSubview(dateLabel)
    }

    private func setLayout() {
        shadowView.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview().inset(8)
        }

        envelopeTopView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        stampView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(32)
        }

        stampIcon.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        letterPaperView.snp.makeConstraints {
            $0.top.equalTo(envelopeTopView.snp.bottom).offset(-8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
        }

        polaroidFrame.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.top.equalToSuperview().offset(14)
            $0.width.equalTo(90)
            $0.height.equalTo(100)
        }

        gifticonImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(6)
            $0.bottom.equalToSuperview().inset(18)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalTo(polaroidFrame.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().inset(12)
        }

        decorLine.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(1)
        }

        fromIcon.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(decorLine.snp.bottom).offset(10)
        }

        fromLabel.snp.makeConstraints {
            $0.leading.equalTo(fromIcon.snp.trailing).offset(4)
            $0.centerY.equalTo(fromIcon)
        }

        giverLabel.snp.makeConstraints {
            $0.leading.equalTo(fromLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(fromIcon)
        }

        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(14)
        }
    }

    func configure(image: UIImage?, title: String, giverName: String?, date: String) {
        gifticonImageView.image = image
        titleLabel.text = title
        giverLabel.text = giverName ?? "알 수 없음"
        dateLabel.text = date
    }
}
