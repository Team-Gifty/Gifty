import Foundation

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
    // This is a dummy implementation for demonstration purposes.
    // In a real application, you would use the actual iOS Keychain services.
    private var storage: [String: String] = [:]

    public func save(type: KeychainType, value: String) {
        print("DUMMY: Saving \(type.rawValue) to mock keychain.")
        storage[type.rawValue] = value
    }

    public func load(type: KeychainType) -> String {
        print("DUMMY: Loading \(type.rawValue) from mock keychain.")
        return storage[type.rawValue] ?? ""
    }

    public func delete(type: KeychainType) {
        print("DUMMY: Deleting \(type.rawValue) from mock keychain.")
        storage.removeValue(forKey: type.rawValue)
    }
}
