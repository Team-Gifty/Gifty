import Foundation
import Moya

final class DIContainer {
    static let shared = DIContainer()

    private init() {}

    // MARK: - DataSource
    func makeAuthRemoteDataSource() -> AuthRemoteDataSourceProtocol {
        return AuthRemoteDataSource()
    }

    // MARK: - Repository
    func makeAuthRepository() -> AuthRepositoryProtocol {
        return AuthRepositoryImpl(remoteDataSource: makeAuthRemoteDataSource())
    }

    // MARK: - UseCase
    func makeLoginUseCase() -> LoginUseCase {
        return LoginUseCase(repository: makeAuthRepository())
    }

    // MARK: - ViewModel
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(loginUseCase: makeLoginUseCase())
    }

    // MARK: - ViewController
    func makeLoginViewController() -> LoginViewController {
        return LoginViewController(viewModel: makeLoginViewModel())
    }
}
