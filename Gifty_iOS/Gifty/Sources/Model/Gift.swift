import Foundation
import RealmSwift

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
