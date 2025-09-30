import Foundation
import RealmSwift

class UserModel: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var nickname: String = ""
    @Persisted var createdAt: Date = Date()
    
    convenience init(nickname: String) {
        self.init()
        self.nickname = nickname
    }
}
