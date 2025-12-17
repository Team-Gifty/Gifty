import Foundation
import Moya

final class NetworkLogger: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        guard let request = request.request else { return }

        print("🚀 [Request] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")

        if let headers = request.allHTTPHeaderFields {
            print("📋 [Headers]")
            headers.forEach { key, value in
                print("  \(key): \(value)")
            }
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("📦 [Body] \(bodyString)")
        }
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            print("✅ [Response] \(response.statusCode) from \(response.request?.url?.absoluteString ?? "")")
            if let jsonString = try? response.mapJSON() {
                print("📥 [Data] \(jsonString)")
            }
        case .failure(let error):
            print("❌ [Error] \(error.localizedDescription)")
            if let response = error.response {
                print("📥 [Error Response] \(response.statusCode)")
                if let data = try? response.mapJSON() {
                    print("📥 [Error Data] \(data)")
                }
            }
        }
    }
}
