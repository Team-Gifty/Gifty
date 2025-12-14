import Foundation
import Combine

protocol AuthServiceProtocol {
    func signUp(request: SignUpRequestDTO) -> AnyPublisher<SignUpResponseDTO, Error>
    func login(request: LoginRequestDTO) -> AnyPublisher<SignUpResponseDTO, Error>
}

class AuthService: AuthServiceProtocol {
    func signUp(request: SignUpRequestDTO) -> AnyPublisher<SignUpResponseDTO, Error> {
        print("Simulating signup for email: \(request.email)")
        
        return Future<SignUpResponseDTO, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Simulate success
                let response = SignUpResponseDTO(
                    accessToken: "simulated_access_token_\(UUID().uuidString)",
                    refreshToken: "simulated_refresh_token_\(UUID().uuidString)"
                )
                promise(.success(response))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func login(request: LoginRequestDTO) -> AnyPublisher<SignUpResponseDTO, Error> {
        print("Simulating login for email: \(request.email)")

        return Future<SignUpResponseDTO, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let response = SignUpResponseDTO(
                    accessToken: "simulated_access_token_\(UUID().uuidString)",
                    refreshToken: "simulated_refresh_token_\(UUID().uuidString)"
                )
                promise(.success(response))
            }
        }
        .eraseToAnyPublisher()
    }
}
