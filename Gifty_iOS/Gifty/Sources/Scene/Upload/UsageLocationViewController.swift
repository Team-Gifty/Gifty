import UIKit
import SnapKit
import Then
import MapKit
import CoreLocation
import Combine

class UsageLocationViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel = UsageLocationViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let searchQueryTextSubject = CurrentValueSubject<String?, Never>(nil)
    private let locationSelectedSubject = PassthroughSubject<MKLocalSearchCompletion, Never>()
    private let confirmButtonTappedSubject = PassthroughSubject<Void, Never>()

    private var searchResults: [MKLocalSearchCompletion] = []
    private let locationManager = CLLocationManager()

    private let titleLabel = UILabel().then {
        $0.text = "어디서 사용하나요?"
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let usageTextField = GiftyTextField(hintText: "사용처 검색")

    private let confirmButton = GiftyButton(buttonText: "확인", isEnabled: false)

    private let searchResultsTableView = UITableView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.withAlphaComponent(0.3).cgColor
        $0.isHidden = true
    }

    private let previewMapView = MKMapView().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
    }

    private let locationInfoContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.withAlphaComponent(0.3).cgColor
        $0.isHidden = true
    }

    private let previewTitleLabel = UILabel().then {
        $0.font = .giftyFont(size: 18)
        $0.textColor = ._6_A_4_C_4_C
        $0.numberOfLines = 1
        $0.textAlignment = .center
    }

    private let previewAddressLabel = UILabel().then {
        $0.font = .giftyFont(size: 14)
        $0.textColor = ._6_A_4_C_4_C.withAlphaComponent(0.6)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }

    var productName: String? {
        didSet {
            viewModel.setProductName(productName)
        }
    }

    var selectedImageName: String? {
        didSet {
            viewModel.setImageName(selectedImageName)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupBindings()
        setupLocationManager()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        usageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)

        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
    }

    // MARK: - Binding
    private func setupBindings() {
        let input = UsageLocationViewModel.Input(
            searchQueryText: searchQueryTextSubject.eraseToAnyPublisher(),
            locationSelected: locationSelectedSubject.eraseToAnyPublisher(),
            confirmButtonTapped: confirmButtonTappedSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self = self else { return }
                self.searchResults = results
                self.searchResultsTableView.isHidden = results.isEmpty
                self.searchResultsTableView.reloadData()
            }
            .store(in: &cancellables)

        output.selectedLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locationInfo in
                guard let self = self, let locationInfo = locationInfo else { return }
                self.showLocationPreview(
                    title: locationInfo.title,
                    address: locationInfo.address,
                    coordinate: locationInfo.coordinate
                )
                self.usageTextField.text = locationInfo.title
                self.searchResultsTableView.isHidden = true
            }
            .store(in: &cancellables)

        output.isConfirmButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.confirmButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)

        output.navigationToExpirationDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                let expirationDateVC = ExpirationDateViewController()
                expirationDateVC.productName = data.productName
                expirationDateVC.usageLocation = data.usageLocation
                expirationDateVC.selectedImageName = data.selectedImageName
                expirationDateVC.latitude = data.latitude
                expirationDateVC.longitude = data.longitude
                self.navigationController?.pushViewController(expirationDateVC, animated: true)
            }
            .store(in: &cancellables)
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func addView() {
        [previewTitleLabel, previewAddressLabel].forEach { locationInfoContainer.addSubview($0) }
        [titleLabel, usageTextField, confirmButton, backButton, searchResultsTableView, previewMapView, locationInfoContainer].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }

        usageTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        searchResultsTableView.snp.makeConstraints {
            $0.top.equalTo(usageTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }

        previewMapView.snp.makeConstraints {
            $0.top.equalTo(usageTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }

        locationInfoContainer.snp.makeConstraints {
            $0.top.equalTo(previewMapView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(80)
        }

        previewTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        previewAddressLabel.snp.makeConstraints {
            $0.top.equalTo(previewTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
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
    @objc private func textFieldDidChange() {
        previewMapView.isHidden = true
        locationInfoContainer.isHidden = true
        searchQueryTextSubject.send(usageTextField.text)
    }

    @objc private func confirmButtonTapped() {
        confirmButtonTappedSubject.send(())
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func showLocationPreview(title: String, address: String, coordinate: CLLocationCoordinate2D) {
        previewTitleLabel.text = title
        previewAddressLabel.text = address

        let region = MKCoordinateRegion(center: coordinate,
                                       latitudinalMeters: 1000,
                                       longitudinalMeters: 1000)
        previewMapView.setRegion(region, animated: false)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        previewMapView.removeAnnotations(previewMapView.annotations)
        previewMapView.addAnnotation(annotation)

        previewMapView.isHidden = false
        locationInfoContainer.isHidden = false
    }
}

// MARK: - CLLocationManagerDelegate
extension UsageLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            viewModel.setCurrentLocation(location)
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location permission denied")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension UsageLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SearchResultCell")
        let result = searchResults[indexPath.row]

        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        cell.textLabel?.font = .giftyFont(size: 16)
        cell.detailTextLabel?.font = .giftyFont(size: 12)
        cell.detailTextLabel?.textColor = ._6_A_4_C_4_C.withAlphaComponent(0.6)
        cell.selectionStyle = .default

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        locationSelectedSubject.send(selectedResult)
    }
}
