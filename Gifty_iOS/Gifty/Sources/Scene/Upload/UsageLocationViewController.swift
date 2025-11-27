
import UIKit
import SnapKit
import Then
import MapKit
import CoreLocation

class UsageLocationViewController: BaseViewController {

    private let titleLabel = UILabel().then {
        $0.text = "어디서 사용하나요?"
        $0.font = .giftyFont(size: 24)
        $0.textColor = ._6_A_4_C_4_C
    }

    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back"), for: .normal)
    }

    private let usageTextField = GiftyTextField(hintText: "사용처")

    private let confirmButton = GiftyButton(buttonText: "확인", isEnabled: true)

    private let searchResultsTableView = UITableView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.withAlphaComponent(0.3).cgColor
        $0.isHidden = true
    }

    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    var productName: String?
    var selectedImageName: String?
    var selectedLatitude: Double?
    var selectedLongitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        usageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)

        setupLocationManager()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self

        updateButtonState()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func addView() {
        [titleLabel, usageTextField, confirmButton, backButton, searchResultsTableView].forEach { view.addSubview($0) }
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

        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }
    
    private func updateButtonState() {
        let isEmpty = usageTextField.text?.isEmpty ?? true
        confirmButton.isEnabled = !isEmpty
    }

    @objc private func textFieldDidChange() {
        updateButtonState()

        guard let query = usageTextField.text, !query.isEmpty else {
            searchResults = []
            searchResultsTableView.isHidden = true
            searchResultsTableView.reloadData()
            return
        }

        if let location = currentLocation {
            let center = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: center, span: span)
            searchCompleter.region = region
        }

        searchCompleter.queryFragment = query
    }

    @objc private func confirmButtonTapped() {
        guard let usage = usageTextField.text, !usage.isEmpty else { return }

        let expirationDateVC = ExpirationDateViewController()
        expirationDateVC.productName = productName
        expirationDateVC.usageLocation = usage
        expirationDateVC.selectedImageName = selectedImageName
        expirationDateVC.latitude = selectedLatitude
        expirationDateVC.longitude = selectedLongitude
        navigationController?.pushViewController(expirationDateVC, animated: true)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension UsageLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil, let location = locations.first {
            currentLocation = location
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

extension UsageLocationViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.isHidden = searchResults.isEmpty
        searchResultsTableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Location search error: \(error.localizedDescription)")
    }
}

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

        let searchRequest = MKLocalSearch.Request(completion: selectedResult)
        let search = MKLocalSearch(request: searchRequest)

        search.start { [weak self] response, error in
            guard let self = self,
                  let coordinate = response?.mapItems.first?.placemark.coordinate else {
                print("Failed to get coordinates: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.selectedLatitude = coordinate.latitude
            self.selectedLongitude = coordinate.longitude
            self.usageTextField.text = selectedResult.title
            self.searchResultsTableView.isHidden = true
            self.updateButtonState()
        }
    }
}
