
import UIKit
import SnapKit
import Then

class ExpirationDateViewController: BaseViewController {

    private let titleLabel = UILabel().then {
        $0.text = "언제까지 써야하나요?"
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .inline
        $0.tintColor = .A_98_E_5_C
        $0.locale = Locale(identifier: "ko_KR")
        $0.minimumDate = Calendar.current.startOfDay(for: Date())
    }

    private let confirmButton = GiftyButton(buttonText: "확인", isEnabled: true)
    
    var productName: String?
    var usageLocation: String?
    var selectedImageName: String?
    var latitude: Double?
    var longitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        if #available(iOS 14.0, *) {
            datePicker.overrideUserInterfaceStyle = .light
        }
    }

    override func addView() {
        [titleLabel, datePicker, confirmButton, backButton].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }

        datePicker.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }

    @objc private func confirmButtonTapped() {
        let expirationDate = datePicker.date

        let memoVC = MemoViewController()
        memoVC.productName = productName
        memoVC.usageLocation = usageLocation
        memoVC.expirationDate = expirationDate
        memoVC.selectedImageName = selectedImageName
        memoVC.latitude = latitude
        memoVC.longitude = longitude
        navigationController?.pushViewController(memoVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
