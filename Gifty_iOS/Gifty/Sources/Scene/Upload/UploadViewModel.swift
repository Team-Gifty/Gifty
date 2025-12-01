import Foundation
import Combine
import UIKit

final class UploadViewModel {

    // MARK: - Input
    struct Input {
        let imageSelected: AnyPublisher<UIImage, Never>
        let informationButtonTapped: AnyPublisher<Void, Never>
    }

    // MARK: - Output
    struct Output {
        let selectedImage: AnyPublisher<UIImage?, Never>
        let selectedImageName: AnyPublisher<String?, Never>
        let isInformationButtonEnabled: AnyPublisher<Bool, Never>
        let navigationToProductName: AnyPublisher<String?, Never>
    }

    // MARK: - Properties
    private let selectedImageSubject = CurrentValueSubject<UIImage?, Never>(nil)
    private let selectedImageNameSubject = CurrentValueSubject<String?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Transform
    func transform(input: Input) -> Output {
        let imageNamePublisher = input.imageSelected
            .map { [weak self] image -> String? in
                self?.saveImageToDocument(image)
            }
            .share()

        imageNamePublisher
            .sink { [weak self] imageName in
                self?.selectedImageNameSubject.send(imageName)
            }
            .store(in: &cancellables)

        input.imageSelected
            .sink { [weak self] image in
                self?.selectedImageSubject.send(image)
            }
            .store(in: &cancellables)

        let isButtonEnabled = selectedImageSubject
            .map { $0 != nil }
            .eraseToAnyPublisher()

        let navigationTrigger = input.informationButtonTapped
            .withLatestFrom(selectedImageNameSubject)
            .eraseToAnyPublisher()

        return Output(
            selectedImage: selectedImageSubject.eraseToAnyPublisher(),
            selectedImageName: selectedImageNameSubject.eraseToAnyPublisher(),
            isInformationButtonEnabled: isButtonEnabled,
            navigationToProductName: navigationTrigger
        )
    }

    // MARK: - Methods
    func clearInputs() {
        selectedImageSubject.send(nil)
        selectedImageNameSubject.send(nil)
    }

    private func saveImageToDocument(_ image: UIImage) -> String? {
        let imageName = UUID().uuidString
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(imageName)

        if let data = image.jpegData(compressionQuality: 1.0) {
            try? data.write(to: fileURL)
            return imageName
        }
        return nil
    }
}

