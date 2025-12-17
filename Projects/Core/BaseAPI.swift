import Foundation
import Moya

enum BaseAPI {
    static let baseURL = "https://leejh08-gifty-api.dsmhs.kr"
}

protocol BaseTargetType: TargetType {}

extension BaseTargetType {
    var baseURL: URL {
        return URL(string: BaseAPI.baseURL)!
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
