import Foundation

struct SignUpRequestDTO: Encodable {
    let email: String
    let name: String
    let password: String
}
