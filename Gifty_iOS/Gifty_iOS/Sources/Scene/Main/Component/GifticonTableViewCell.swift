import UIKit
import SnapKit
import Then

class GifticonTableViewCell: UITableViewCell {

    static let identifier = "GifticonTableViewCell"

    private let containerView = UIView().then {
        $0.backgroundColor = .FFFEF_7
        $0.layer.cornerRadius = 3
        $0.clipsToBounds = true
    }

    private let gifticonImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 3
        $0.backgroundColor = .lightGray
    }

    private let titleLabel = UILabel().then {
        $0.font = .cellFont(size: 11)
        $0.textColor = UIColor(named: "6A4C4C")
        $0.text = "제목"
    }

    private let usageLabel = UILabel().then {
        $0.font = .cellFont(size: 9)
        $0.textColor = UIColor(named: "6A4C4C")
        $0.text = "사용처"
    }

    private let dateLabel = UILabel().then {
        $0.font = .cellFont(size: 12)
        $0.textColor = UIColor(named: "6A4C4C")
        $0.text = "YYYY.MM.DD"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .FFF_7_EC

        contentView.layer.shadowColor = UIColor.CBBDB_1.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 3
        contentView.layer.masksToBounds = false

        addView()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.shadowPath = UIBezierPath(roundedRect: containerView.frame, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    private func addView() {
        contentView.addSubview(containerView)
        containerView.addSubview(gifticonImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(usageLabel)
        containerView.addSubview(dateLabel)
    }

    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.width.equalTo(331)
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
        usageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(11)
            $0.leading.equalTo(titleLabel.snp.leading)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.bottom.equalToSuperview().offset(-9)
        }
    }

    func configure(image: UIImage?, title: String, usage: String, date: String) {
        gifticonImageView.image = image
        titleLabel.text = title
        usageLabel.text = usage
        dateLabel.text = date
    }
}
