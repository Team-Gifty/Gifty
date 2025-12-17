import Foundation
import Combine

final class LoginViewModel {
    // MARK: - Input
    struct Input {
        let emailText: AnyPublisher<String, Never>
        let passwordText: AnyPublisher<String, Never>
        let loginButtonTapped: AnyPublisher<Void, Never>
    }

    // MARK: - Output
    struct Output {
        let isLoginButtonEnabled: AnyPublisher<Bool, Never>
        let loginResult: AnyPublisher<Result<Void, Error>, Never>
        let isLoading: AnyPublisher<Bool, Never>
    }

    // MARK: - Properties
    private let loginUseCase: LoginUseCase
    private let jwtStore: JwtStore
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        loginUseCase: LoginUseCase,
        jwtStore: JwtStore = .shared
    ) {
        self.loginUseCase = loginUseCase
        self.jwtStore = jwtStore
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        let loginButtonEnabled = Publishers.CombineLatest(
            input.emailText,
            input.passwordText
        )
        .map { email, password in
            !email.isEmpty && !password.isEmpty && email.contains("@")
        }
        .eraseToAnyPublisher()

        let loadingSubject = PassthroughSubject<Bool, Never>()

        let loginResult = input.loginButtonTapped
            .withLatestFrom(Publishers.CombineLatest(input.emailText, input.passwordText))
            .handleEvents(receiveOutput: { _ in
                loadingSubject.send(true)
            })
            .flatMap { [weak self] email, password -> AnyPublisher<Result<Void, Error>, Never> in
                guard let self = self else {
                    return Just(.failure(NSError(domain: "LoginViewModel", code: -1)))
                        .eraseToAnyPublisher()
                }

                return self.loginUseCase.execute(email: email, password: password)
                    .map { [weak self] authEntity -> Result<Void, Error> in
                        self?.jwtStore.accessToken = authEntity.accessToken
                        self?.jwtStore.refreshToken = authEntity.refreshToken
                        return .success(())
                    }
                    .catch { error -> AnyPublisher<Result<Void, Error>, Never> in
                        Just(.failure(error)).eraseToAnyPublisher()
                    }
                    .handleEvents(receiveOutput: { _ in
                        loadingSubject.send(false)
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return Output(
            isLoginButtonEnabled: loginButtonEnabled,
            loginResult: loginResult,
            isLoading: loadingSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Publisher Extension
extension Publisher {
    func withLatestFrom<Other: Publisher>(_ other: Other) -> AnyPublisher<Other.Output, Failure>
    where Other.Failure == Failure {
        let upstream = self

        return other
            .map { second in upstream.map { _ in second } }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
