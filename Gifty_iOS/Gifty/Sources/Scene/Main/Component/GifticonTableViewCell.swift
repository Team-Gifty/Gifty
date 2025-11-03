import UIKit
import SnapKit
import Then

class GifticonTableViewCell: UITableViewCell {

    static let identifier = "GifticonTableViewCell"

    private let shadowView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 3
        $0.layer.shadowColor = UIColor(named: "595959")?.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowOffset = CGSize(width: 1, height: 2.5)
        $0.layer.shadowRadius = 2
        $0.layer.masksToBounds = false
    }

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
    
    private let expiredLabel = UILabel().then {
        $0.text = "만료됨"
        $0.font = .cellFont(size: 10)
        $0.textColor = UIColor(named: "9B1C1C")
        $0.backgroundColor = UIColor(named: "9B1C1C")?.withAlphaComponent(0.1)
        $0.layer.cornerRadius = 3
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
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
        containerView.addSubview(usageLabel)
        containerView.addSubview(expiredLabel)
        containerView.addSubview(dateLabel)
    }

    private func setLayout() {
        shadowView.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
        
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
        
        expiredLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.bottom.equalTo(dateLabel.snp.top).offset(-4)
            $0.height.equalTo(18)
            $0.width.equalTo(50)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.bottom.equalToSuperview().offset(-9)
        }
    }

    func configure(image: UIImage?, title: String, usage: String, date: String, isExpired: Bool = false) {
        gifticonImageView.image = image
        titleLabel.text = title
        usageLabel.text = usage
        dateLabel.text = date
        
        // 만료 상태 처리
        if isExpired {
            expiredLabel.isHidden = false
            dateLabel.textColor = UIColor(named: "7F7D7D")
            containerView.alpha = 0.7
            shadowView.alpha = 0.7
        } else {
            expiredLabel.isHidden = true
            dateLabel.textColor = UIColor(named: "6A4C4C")
            containerView.alpha = 1.0
            shadowView.alpha = 1.0
        }
    }
}
