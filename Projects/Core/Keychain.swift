import Foundation
import Security

public enum KeychainType: String {
    case accessToken
    case refreshToken
    case service
}

public protocol Keychain {
    func save(type: KeychainType, value: String)
    func load(type: KeychainType) -> String
    func delete(type: KeychainType)
}

public final class KeychainImpl: Keychain {
    private let service = "com.gifty.app"

    public init() {}

    public func save(type: KeychainType, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: type.rawValue,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("✅ Keychain: Saved \(type.rawValue)")
        } else {
            print("❌ Keychain: Failed to save \(type.rawValue) - Status: \(status)")
        }
    }

    public func load(type: KeychainType) -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: type.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            print("✅ Keychain: Loaded \(type.rawValue)")
            return value
        } else {
            print("⚠️ Keychain: Failed to load \(type.rawValue) - Status: \(status)")
            return ""
        }
    }

    public func delete(type: KeychainType) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: type.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            print("✅ Keychain: Deleted \(type.rawValue)")
        } else {
            print("❌ Keychain: Failed to delete \(type.rawValue) - Status: \(status)")
        }
    }
}
