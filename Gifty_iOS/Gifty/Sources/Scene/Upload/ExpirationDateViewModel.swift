import Foundation
import Combine

final class ExpirationDateViewModel {

    // MARK: - Input
    struct Input {
        let dateSelected: AnyPublisher<Date, Never>
        let confirmButtonTapped: AnyPublisher<Void, Never>
    }

    // MARK: - Output
    struct Output {
        let navigationToMemo: AnyPublisher<NavigationData, Never>
    }

    struct NavigationData {
        let productName: String?
        let usageLocation: String?
        let expirationDate: Date
        let selectedImageName: String?
        let latitude: Double?
        let longitude: Double?
    }

    // MARK: - Properties
    private let selectedDateSubject = CurrentValueSubject<Date, Never>(Date())
    private let productNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let usageLocationSubject = CurrentValueSubject<String?, Never>(nil)
    private let selectedImageNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let latitudeSubject = CurrentValueSubject<Double?, Never>(nil)
    private let longitudeSubject = CurrentValueSubject<Double?, Never>(nil)

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Methods
    func setProductName(_ name: String?) {
        productNameSubject.send(name)
    }

    func setUsageLocation(_ location: String?) {
        usageLocationSubject.send(location)
    }

    func setImageName(_ imageName: String?) {
        selectedImageNameSubject.send(imageName)
    }

    func setLatitude(_ latitude: Double?) {
        latitudeSubject.send(latitude)
    }

    func setLongitude(_ longitude: Double?) {
        longitudeSubject.send(longitude)
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        input.dateSelected
            .sink { [weak self] date in
                self?.selectedDateSubject.send(date)
            }
            .store(in: &cancellables)

        let navigationTrigger = input.confirmButtonTapped
            .map { [weak self] _ -> NavigationData? in
                guard let self = self else { return nil }
                return NavigationData(
                    productName: self.productNameSubject.value,
                    usageLocation: self.usageLocationSubject.value,
                    expirationDate: self.selectedDateSubject.value,
                    selectedImageName: self.selectedImageNameSubject.value,
                    latitude: self.latitudeSubject.value,
                    longitude: self.longitudeSubject.value
                )
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()

        return Output(
            navigationToMemo: navigationTrigger
        )
    }
}
