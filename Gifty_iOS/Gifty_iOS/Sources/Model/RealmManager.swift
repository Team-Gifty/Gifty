import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    private var realm: Realm {
        do {
            let config = Realm.Configuration(schemaVersion: 2)
            return try Realm(configuration: config)
        } catch {
            fatalError("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    private init() {}
    
    // MARK: - User
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
    
    // MARK: - Gift
    func saveGift(name: String, usage: String, expiryDate: Date, memo: String?, imagePath: String) {
        guard let user = getUser() else { return }
        
        let newGift = Gift()
        newGift.id = ObjectId.generate()
        newGift.name = name
        newGift.usage = usage
        newGift.expiryDate = expiryDate
        newGift.memo = memo
        newGift.imagePath = imagePath
        
        try! realm.write {
            user.gifts.append(newGift)
        }
    }
    
    func getGifts(sortedBy sortOrder: SortOrder = .byRegistrationDate) -> Results<Gift> {
        switch sortOrder {
        case .byRegistrationDate:
            return realm.objects(Gift.self).sorted(byKeyPath: "id", ascending: false)
        case .byExpiryDate:
            return realm.objects(Gift.self).sorted(byKeyPath: "expiryDate", ascending: true)
        }
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
}