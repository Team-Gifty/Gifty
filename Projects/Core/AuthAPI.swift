import Foundation
import Moya

enum AuthAPI {
    case login(email: String, password: String)
    case signUp(email: String, password: String, name: String)
}

extension AuthAPI: BaseTargetType {
    var path: String {
        switch self {
        case .login:
            return "/users/login"
        case .signUp:
            return "/users/signup"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .signUp:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .login(let email, let password):
            return .requestJSONEncodable(LoginRequest(email: email, password: password))
        case .signUp(let email, let password, let name):
            return .requestJSONEncodable(SignUpRequest(email: email, password: password, name: name))
        }
    }
}

// MARK: - Request Models
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SignUpRequest: Encodable {
    let email: String
    let name: String
    let password: String
}

// MARK: - Response Models
struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}
