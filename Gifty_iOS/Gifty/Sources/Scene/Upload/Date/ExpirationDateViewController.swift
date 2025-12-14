import UIKit
import SnapKit
import Then
import Combine

class ExpirationDateViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel = ExpirationDateViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let dateSelectedSubject = PassthroughSubject<Date, Never>()
    private let confirmButtonTappedSubject = PassthroughSubject<Void, Never>()

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

    var productName: String? {
        didSet {
            viewModel.setProductName(productName)
        }
    }

    var usageLocation: String? {
        didSet {
            viewModel.setUsageLocation(usageLocation)
        }
    }

    var selectedImageName: String? {
        didSet {
            viewModel.setImageName(selectedImageName)
        }
    }

    var latitude: Double? {
        didSet {
            viewModel.setLatitude(latitude)
        }
    }

    var longitude: Double? {
        didSet {
            viewModel.setLongitude(longitude)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        if #available(iOS 14.0, *) {
            datePicker.overrideUserInterfaceStyle = .light
        }
    }

    // MARK: - Binding
    private func setupBindings() {
        let input = ExpirationDateViewModel.Input(
            dateSelected: dateSelectedSubject.eraseToAnyPublisher(),
            confirmButtonTapped: confirmButtonTappedSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.navigationToMemo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                let memoVC = MemoViewController()
                memoVC.productName = data.productName
                memoVC.usageLocation = data.usageLocation
                memoVC.expirationDate = data.expirationDate
                memoVC.selectedImageName = data.selectedImageName
                memoVC.latitude = data.latitude
                memoVC.longitude = data.longitude
                self.navigationController?.pushViewController(memoVC, animated: true)
            }
            .store(in: &cancellables)
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

    // MARK: - Actions
    @objc private func dateChanged() {
        dateSelectedSubject.send(datePicker.date)
    }

    @objc private func confirmButtonTapped() {
        confirmButtonTappedSubject.send(())
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
