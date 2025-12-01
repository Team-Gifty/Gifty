import Foundation
import Combine

final class ProductNameViewModel {

    // MARK: - Input
    struct Input {
        let productNameText: AnyPublisher<String?, Never>
        let confirmButtonTapped: AnyPublisher<Void, Never>
    }

    // MARK: - Output
    struct Output {
        let isConfirmButtonEnabled: AnyPublisher<Bool, Never>
        let navigationToUsageLocation: AnyPublisher<(name: String, imageName: String?), Never>
    }

    // MARK: - Properties
    private let selectedImageNameSubject = CurrentValueSubject<String?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Methods
    func setImageName(_ imageName: String?) {
        selectedImageNameSubject.send(imageName)
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        let isButtonEnabled = input.productNameText
            .map { text in
                !(text?.isEmpty ?? true)
            }
            .eraseToAnyPublisher()

        let navigationTrigger = input.confirmButtonTapped
            .withLatestFrom(input.productNameText)
            .compactMap { [weak self] name -> (name: String, imageName: String?)? in
                guard let self = self, let name = name, !name.isEmpty else { return nil }
                return (name: name, imageName: self.selectedImageNameSubject.value)
            }
            .eraseToAnyPublisher()

        return Output(
            isConfirmButtonEnabled: isButtonEnabled,
            navigationToUsageLocation: navigationTrigger
        )
    }
}
