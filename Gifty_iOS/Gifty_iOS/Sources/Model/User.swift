
import Foundation
import RealmSwift

class User: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var nickname: String
    @Persisted var createdAt: Date
    @Persisted var updatedAt: Date
    @Persisted var gifts: List<Gift>
}
