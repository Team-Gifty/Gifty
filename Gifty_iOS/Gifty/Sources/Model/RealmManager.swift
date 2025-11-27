import Foundation
import RealmSwift
import CoreLocation


class RealmManager {
    static let shared = RealmManager()

    private let appGroupIdentifier = "group.com.ahyeonlee.gifty.shared"

    var realm: Realm {
        do {
            let config = Realm.Configuration(
                fileURL: getRealmFileURL(),
                schemaVersion: 6,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 3 {
                        migration.enumerateObjects(ofType: "Gift") { oldObject, newObject in
                            newObject?["isExpired"] = false
                        }
                    }
                    if oldSchemaVersion < 5 {
                        migration.enumerateObjects(ofType: "Gift") { oldObject, newObject in
                            newObject?["latitude"] = nil
                            newObject?["longitude"] = nil
                        }
                    }
                    if oldSchemaVersion < 6 {
                        migration.enumerateObjects(ofType: "Gift") { oldObject, newObject in
                            newObject?["isArchived"] = false
                            newObject?["giverName"] = nil
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

    // App Group 컨테이너 내 Realm 파일 경로 반환
    private func getRealmFileURL() -> URL? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            print("⚠️ App Group 컨테이너를 찾을 수 없습니다. 기본 경로를 사용합니다.")
            return Realm.Configuration.defaultConfiguration.fileURL
        }
        return containerURL.appendingPathComponent("default.realm")
    }

    func saveNickname(_ nickname: String) {
        let now = Date()
        if let existingUser = realm.objects(User.self).first {
            try! realm.write {
                existingUser.nickname = nickname
                existingUser.updatedAt = now
            }
        } else {
            let newUser = User()
            newUser.id = ObjectId.generate()
            newUser.nickname = nickname
            newUser.createdAt = now
            newUser.updatedAt = now
            try! realm.write {
                realm.add(newUser)
            }
        }
    }

    func getUser() -> User? {
        return realm.objects(User.self).first
    }

    func deleteUser() {
        try! realm.write {
            realm.delete(realm.objects(User.self))
        }
    }

    func saveGift(name: String, usage: String, expiryDate: Date, memo: String?, imagePath: String, latitude: Double? = nil, longitude: Double? = nil) -> Gift? {
        guard let user = getUser() else { return nil }

        let newGift = Gift()
        newGift.id = ObjectId.generate()
        newGift.name = name
        newGift.usage = usage
        newGift.expiryDate = expiryDate
        newGift.memo = memo
        newGift.imagePath = imagePath
        newGift.latitude = latitude
        newGift.longitude = longitude

        try! realm.write {
            user.gifts.append(newGift)
        }
        return newGift
    }

    func getGifts(sortedBy sortOrder: SortOrder = .byRegistrationDate) -> Results<Gift> {
        let nonArchivedGifts = realm.objects(Gift.self).filter("isArchived == false")
        switch sortOrder {
        case .byRegistrationDate:
            return nonArchivedGifts.sorted(byKeyPath: "id", ascending: false)
        case .byExpiryDate:
            return nonArchivedGifts.sorted(byKeyPath: "expiryDate", ascending: true)
        case .byDistance:
            return nonArchivedGifts.sorted(byKeyPath: "id", ascending: false)
        }
    }

    func getGiftsSortedByDistance(currentLocation: CLLocation?) -> [Gift] {
        let allGifts = Array(realm.objects(Gift.self).filter("isArchived == false"))

        guard let currentLocation = currentLocation else {
            return allGifts
        }

        return allGifts.sorted { gift1, gift2 in
            let distance1 = getDistance(from: currentLocation, to: gift1)
            let distance2 = getDistance(from: currentLocation, to: gift2)

            if distance1 == nil && distance2 == nil {
                return false
            } else if distance1 == nil {
                return false
            } else if distance2 == nil {
                return true
            } else {
                return distance1! < distance2!
            }
        }
    }

    private func getDistance(from location: CLLocation, to gift: Gift) -> Double? {
        guard let lat = gift.latitude, let lon = gift.longitude else {
            return nil
        }
        let giftLocation = CLLocation(latitude: lat, longitude: lon)
        return location.distance(from: giftLocation)
    }

    func searchGifts(name: String) -> Results<Gift> {
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", name)
        return realm.objects(Gift.self).filter(predicate)
    }

    func searchGifts(query: String, filter: SearchFilter) -> Results<Gift> {
        let predicate: NSPredicate
        switch filter {
        case .productName:
            predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
        case .usage:
            predicate = NSPredicate(format: "usage CONTAINS[c] %@", query)
        }
        return realm.objects(Gift.self).filter(predicate)
    }

    func deleteGift(_ gift: Gift) {
        try! realm.write {
            realm.delete(gift)
        }
    }

    func updateGift(_ gift: Gift, name: String, usage: String, expiryDate: Date, memo: String?, latitude: Double? = nil, longitude: Double? = nil) {
        try! realm.write {
            gift.name = name
            gift.usage = usage
            gift.expiryDate = expiryDate
            gift.memo = memo
            gift.latitude = latitude
            gift.longitude = longitude
        }
    }

    func isDuplicateGiftName(_ name: String, excludingGift: Gift? = nil) -> Bool {
        let predicate = NSPredicate(format: "name ==[c] %@", name)
        let results = realm.objects(Gift.self).filter(predicate)
        
        if let excludingGift = excludingGift {
            return results.filter("id != %@", excludingGift.id).count > 0
        } else {
            return results.count > 0
        }
    }

    func getGift(by idString: String) -> Gift? {
        do {
            let objectId = try ObjectId(string: idString)
            return realm.object(ofType: Gift.self, forPrimaryKey: objectId)
        } catch {
            print("❌ 유효하지 않은 ObjectId: \(idString)")
            return nil
        }
    }
}
