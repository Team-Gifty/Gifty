import Foundation
import Combine
import MapKit
import CoreLocation

final class UsageLocationViewModel: NSObject {

    // MARK: - Input
    struct Input {
        let searchQueryText: AnyPublisher<String?, Never>
        let locationSelected: AnyPublisher<MKLocalSearchCompletion, Never>
        let confirmButtonTapped: AnyPublisher<Void, Never>
    }

    // MARK: - Output
    struct Output {
        let searchResults: AnyPublisher<[MKLocalSearchCompletion], Never>
        let selectedLocation: AnyPublisher<LocationInfo?, Never>
        let isConfirmButtonEnabled: AnyPublisher<Bool, Never>
        let navigationToExpirationDate: AnyPublisher<NavigationData, Never>
    }

    struct LocationInfo {
        let title: String
        let address: String
        let coordinate: CLLocationCoordinate2D
    }

    struct NavigationData {
        let productName: String?
        let usageLocation: String
        let selectedImageName: String?
        let latitude: Double?
        let longitude: Double?
    }

    // MARK: - Properties
    private let searchCompleter = MKLocalSearchCompleter()
    private let searchResultsSubject = PassthroughSubject<[MKLocalSearchCompletion], Never>()
    private let selectedLocationSubject = CurrentValueSubject<LocationInfo?, Never>(nil)
    private let currentLocationSubject = CurrentValueSubject<CLLocation?, Never>(nil)

    private let productNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let selectedImageNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let usageLocationTextSubject = CurrentValueSubject<String?, Never>(nil)

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
    }

    // MARK: - Methods
    func setProductName(_ name: String?) {
        productNameSubject.send(name)
    }

    func setImageName(_ imageName: String?) {
        selectedImageNameSubject.send(imageName)
    }

    func setCurrentLocation(_ location: CLLocation?) {
        currentLocationSubject.send(location)
        if let location = location {
            let center = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: center, span: span)
            searchCompleter.region = region
        }
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        input.searchQueryText
            .sink { [weak self] query in
                guard let self = self else { return }
                if let query = query, !query.isEmpty {
                    self.searchCompleter.queryFragment = query
                } else {
                    self.searchResultsSubject.send([])
                }
            }
            .store(in: &cancellables)

        let locationInfoPublisher = input.locationSelected
            .flatMap { [weak self] completion -> AnyPublisher<LocationInfo?, Never> in
                guard let self = self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return self.fetchLocationInfo(for: completion)
            }
            .eraseToAnyPublisher()

        locationInfoPublisher
            .sink { [weak self] locationInfo in
                self?.selectedLocationSubject.send(locationInfo)
                if let locationInfo = locationInfo {
                    self?.usageLocationTextSubject.send(locationInfo.title)
                }
            }
            .store(in: &cancellables)

        let isButtonEnabled = selectedLocationSubject
            .map { $0 != nil }
            .eraseToAnyPublisher()

        let navigationTrigger = input.confirmButtonTapped
            .compactMap { [weak self] _ -> NavigationData? in
                guard let self = self,
                      let usageLocation = self.usageLocationTextSubject.value,
                      !usageLocation.isEmpty else { return nil }

                return NavigationData(
                    productName: self.productNameSubject.value,
                    usageLocation: usageLocation,
                    selectedImageName: self.selectedImageNameSubject.value,
                    latitude: self.selectedLocationSubject.value?.coordinate.latitude,
                    longitude: self.selectedLocationSubject.value?.coordinate.longitude
                )
            }
            .eraseToAnyPublisher()

        return Output(
            searchResults: searchResultsSubject.eraseToAnyPublisher(),
            selectedLocation: locationInfoPublisher,
            isConfirmButtonEnabled: isButtonEnabled,
            navigationToExpirationDate: navigationTrigger
        )
    }

    private func fetchLocationInfo(for completion: MKLocalSearchCompletion) -> AnyPublisher<LocationInfo?, Never> {
        return Future<LocationInfo?, Never> { promise in
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)

            search.start { response, error in
                guard let mapItem = response?.mapItems.first else {
                    print("Failed to get coordinates: \(error?.localizedDescription ?? "Unknown error")")
                    promise(.success(nil))
                    return
                }

                let coordinate = mapItem.placemark.coordinate
                let locationInfo = LocationInfo(
                    title: completion.title,
                    address: completion.subtitle,
                    coordinate: coordinate
                )
                promise(.success(locationInfo))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension UsageLocationViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResultsSubject.send(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Location search error: \(error.localizedDescription)")
        searchResultsSubject.send([])
    }
}
