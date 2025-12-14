import UIKit
import MapKit
import SnapKit
import Then

class LocationMapViewController: UIViewController {

    private let mapView = MKMapView().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.font = .giftyFont(size: 20)
        $0.textColor = ._6_A_4_C_4_C
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }

    private let addressLabel = UILabel().then {
        $0.font = .giftyFont(size: 14)
        $0.textColor = ._6_A_4_C_4_C.withAlphaComponent(0.6)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }

    private let openMapButton = UIButton().then {
        $0.setTitle("지도 앱에서 열기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .A_98_E_5_C
        $0.titleLabel?.font = .giftyFont(size: 16)
        $0.layer.cornerRadius = 12
    }

    private var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .FFF_7_EC
        setupViews()
        setupLayout()
        openMapButton.addTarget(self, action: #selector(openMapButtonTapped), for: .touchUpInside)
    }

    func configure(title: String, latitude: Double, longitude: Double) {
        titleLabel.text = title
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        if let coordinate = coordinate {
            let region = MKCoordinateRegion(center: coordinate,
                                           latitudinalMeters: 1000,
                                           longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = title
            mapView.addAnnotation(annotation)

            fetchAddress(latitude: latitude, longitude: longitude)
        }
    }

    private func fetchAddress(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first,
                  error == nil else {
                return
            }

            var addressComponents: [String] = []
            if let locality = placemark.locality {
                addressComponents.append(locality)
            }
            if let subLocality = placemark.subLocality {
                addressComponents.append(subLocality)
            }
            if let thoroughfare = placemark.thoroughfare {
                addressComponents.append(thoroughfare)
            }

            let address = addressComponents.joined(separator: " ")
            self.addressLabel.text = address
        }
    }

    @objc private func openMapButtonTapped() {
        guard let coordinate = coordinate else { return }

        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = titleLabel.text
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func setupViews() {
        [titleLabel, mapView, addressLabel, openMapButton].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        mapView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(300)
        }

        addressLabel.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        openMapButton.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
}
