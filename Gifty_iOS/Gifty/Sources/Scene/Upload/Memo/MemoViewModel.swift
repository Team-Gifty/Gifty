import Foundation
import Combine

final class MemoViewModel {

    // MARK: - Input
    struct Input {
        let memoText: AnyPublisher<String?, Never>
        let registerButtonTapped: AnyPublisher<Void, Never>
    }

    // MARK: - Output
    struct Output {
        let showDuplicateAlert: AnyPublisher<Void, Never>
        let registrationCompleted: AnyPublisher<Void, Never>
    }

    // MARK: - Properties
    private let memoTextSubject = CurrentValueSubject<String?, Never>(nil)
    private let productNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let usageLocationSubject = CurrentValueSubject<String?, Never>(nil)
    private let expirationDateSubject = CurrentValueSubject<Date?, Never>(nil)
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

    func setExpirationDate(_ date: Date?) {
        expirationDateSubject.send(date)
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
        input.memoText
            .sink { [weak self] text in
                self?.memoTextSubject.send(text)
            }
            .store(in: &cancellables)

        let duplicateCheckPublisher = PassthroughSubject<Void, Never>()
        let registrationSuccessPublisher = PassthroughSubject<Void, Never>()

        input.registerButtonTapped
            .sink { [weak self] _ in
                guard let self = self,
                      let name = self.productNameSubject.value,
                      let usage = self.usageLocationSubject.value,
                      let expiryDate = self.expirationDateSubject.value,
                      let imageName = self.selectedImageNameSubject.value else {
                    return
                }

                if RealmManager.shared.isDuplicateGiftName(name) {
                    duplicateCheckPublisher.send(())
                    return
                }

                let memo = self.memoTextSubject.value
                let latitude = self.latitudeSubject.value
                let longitude = self.longitudeSubject.value

                if let newGift = RealmManager.shared.saveGift(
                    name: name,
                    usage: usage,
                    expiryDate: expiryDate,
                    memo: memo,
                    imagePath: imageName,
                    latitude: latitude,
                    longitude: longitude
                ) {
                    NotificationManager.shared.scheduleImmediateNotification(for: newGift)
                    NotificationManager.shared.scheduleDailySummaryNotification()

                    if latitude != nil && longitude != nil {
                        GeofenceManager.shared.addGeofence(for: newGift)
                    }

                    registrationSuccessPublisher.send(())
                }
            }
            .store(in: &cancellables)

        return Output(
            showDuplicateAlert: duplicateCheckPublisher.eraseToAnyPublisher(),
            registrationCompleted: registrationSuccessPublisher.eraseToAnyPublisher()
        )
    }
}
