import UIKit
import SnapKit
import Then

class GifticonTableViewCell: UITableViewCell {

    static let identifier = "GifticonTableViewCell"
    
    private let containerView = UIView().then {
        $0.backgroundColor = .FFFEF_7
        $0.layer.cornerRadius = 3
        $0.clipsToBounds = true
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 100
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
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
        
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addView() {
        contentView.addSubview(containerView)
        containerView.addSubview(gifticonImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(usageLabel)
        containerView.addSubview(dateLabel)
    }

    private func setLayout() {
        containerView.snp.makeConstraints { make in
            make.width.equalTo(331)
            make.height.equalTo(89)
            make.center.equalToSuperview()
        }
        
        gifticonImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(13)
            make.width.height.equalTo(73.3)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(gifticonImageView.snp.top).offset(4)
            make.leading.equalTo(gifticonImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        usageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(11)
            make.leading.equalTo(titleLabel.snp.leading)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-9)
        }
    }

    func configure(image: UIImage?, title: String, usage: String, date: String) {
        gifticonImageView.image = image
        titleLabel.text = title
        usageLabel.text = usage
        dateLabel.text = date
    }
}
