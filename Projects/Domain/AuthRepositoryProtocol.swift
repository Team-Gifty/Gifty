import Foundation
import Combine

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) -> AnyPublisher<AuthEntity, Error>
    func signUp(email: String, password: String, name: String) -> AnyPublisher<AuthEntity, Error>
}
