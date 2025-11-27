import Foundation
import RealmSwift

enum SortOrder {
    case byExpiryDate
    case byRegistrationDate
}

class Gift: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var usage: String
    @Persisted var expiryDate: Date
    @Persisted var memo: String?
    @Persisted var imagePath: String
    @Persisted var isExpired: Bool = false

    var checkIsExpired: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expiryDay = calendar.startOfDay(for: expiryDate)
        return expiryDay < today
    }
}

class User: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var nickname: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var gifts: List<Gift>
}

class RealmManager {
    static let shared = RealmManager()
    private let appGroupIdentifier = "group.com.ahyeonlee.gifty.shared"

    var realm: Realm {
        do {
            let config = Realm.Configuration(
                fileURL: getRealmFileURL(),
                schemaVersion: 4,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 3 {
                        migration.enumerateObjects(ofType: "Gift") { oldObject, newObject in
                            newObject?["isExpired"] = false
                        }
                    }
                }
            )
            return try Realm(configuration: config)
        } catch {
            fatalError("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }

    private init() {}

    private func getRealmFileURL() -> URL? {
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return containerURL.appendingPathComponent("default.realm")
        }
        return Realm.Configuration.defaultConfiguration.fileURL
    }

    func getGifts(sortedBy sortOrder: SortOrder = .byRegistrationDate) -> Results<Gift> {
        switch sortOrder {
        case .byRegistrationDate:
            return realm.objects(Gift.self).sorted(byKeyPath: "id", ascending: false)
        case .byExpiryDate:
            return realm.objects(Gift.self).sorted(byKeyPath: "expiryDate", ascending: true)
        }
    }
}
