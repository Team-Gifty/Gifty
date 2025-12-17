import Foundation
import Moya
import CombineMoya
import Combine

protocol AuthRemoteDataSourceProtocol {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error>
    func signUp(email: String, password: String, name: String) -> AnyPublisher<AuthResponse, Error>
}

final class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    private let provider: MoyaProvider<AuthAPI>

    init(provider: MoyaProvider<AuthAPI> = MoyaProvider<AuthAPI>(plugins: [NetworkLogger()])) {
        self.provider = provider
    }

    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        return provider.requestPublisher(.login(email: email, password: password))
            .map(AuthResponse.self)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func signUp(email: String, password: String, name: String) -> AnyPublisher<AuthResponse, Error> {
        return provider.requestPublisher(.signUp(email: email, password: password, name: name))
            .map(AuthResponse.self)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
