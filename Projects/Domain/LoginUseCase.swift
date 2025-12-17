import Foundation
import Combine

final class LoginUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, password: String) -> AnyPublisher<AuthEntity, Error> {
        return repository.login(email: email, password: password)
    }
}
