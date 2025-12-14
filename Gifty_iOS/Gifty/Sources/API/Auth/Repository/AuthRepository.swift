import Foundation
import Combine

protocol AuthRepositoryProtocol {
    func signUp(email: String, name: String, password: String) -> AnyPublisher<SignUpResponseDTO, Error>
    func login(email: String, password: String) -> AnyPublisher<SignUpResponseDTO, Error>
}

class AuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func signUp(email: String, name: String, password: String) -> AnyPublisher<SignUpResponseDTO, Error> {
        let requestDTO = SignUpRequestDTO(email: email, name: name, password: password)
        return authService.signUp(request: requestDTO)
    }

    func login(email: String, password: String) -> AnyPublisher<SignUpResponseDTO, Error> {
        let requestDTO = LoginRequestDTO(email: email, password: password)
        return authService.login(request: requestDTO)
    }
}
