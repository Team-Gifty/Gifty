import Foundation
import Combine

final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSourceProtocol

    init(remoteDataSource: AuthRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func login(email: String, password: String) -> AnyPublisher<AuthEntity, Error> {
        return remoteDataSource.login(email: email, password: password)
            .map { response in
                AuthEntity(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            }
            .eraseToAnyPublisher()
    }

    func signUp(email: String, password: String, name: String) -> AnyPublisher<AuthEntity, Error> {
        return remoteDataSource.signUp(email: email, password: password, name: name)
            .map { response in
                AuthEntity(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            }
            .eraseToAnyPublisher()
    }
}
