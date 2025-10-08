import UIKit
import SnapKit
import Then

struct Gifticon {
    let image: String
    let title: String
    let usage: String
    let date: String
}

class MainViewController: BaseViewController {
    private let iconImageView = UIImageView().then {
        $0.image = UIImage(named: "GiftyBox")
    }

    private let titleLabel = UILabel().then {
        $0.text = "이거주희님의 교환권"
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .nicknameFont(size: 15)
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

    private var gifticonData: [Gifticon] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        gifticonTableView.dataSource = self
        gifticonTableView.delegate = self
        view.backgroundColor = .FFF_7_EC
        setupSampleData()
        updateUI()
    }

    override func addView() {
        [
            iconImageView,
            titleLabel,
            noneLabel,
            boxImageView,
            gifticonTableView
        ].forEach { view.addSubview($0) }
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

        gifticonTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-81)
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

    private func setupSampleData() {
        gifticonData.append(Gifticon(image: "GiftyBox", title: "스타벅스 아메리카노", usage: "스타벅스", date: "2025.12.25"))
        gifticonData.append(Gifticon(image: "GiftyBox", title: "투썸플레이스 케이크", usage: "투썸플레이스", date: "2025.11.10"))
        gifticonData.append(Gifticon(image: "GiftyBox", title: "BHC 치킨", usage: "BHC", date: "2025.10.31"))
    }

    private func updateUI() {
        if gifticonData.isEmpty {
            gifticonTableView.isHidden = true
            noneLabel.isHidden = false
            boxImageView.isHidden = false
        } else {
            gifticonTableView.isHidden = false
            noneLabel.isHidden = true
            boxImageView.isHidden = true
            gifticonTableView.reloadData()
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gifticonData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GifticonTableViewCell.identifier, for: indexPath) as? GifticonTableViewCell else {
            return UITableViewCell()
        }

        let data = gifticonData[indexPath.row]
        cell.configure(image: UIImage(named: data.image), title: data.title, usage: data.usage, date: data.date)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Height for cell(89) + spacing(13) = 102
        return 102
    }
}
