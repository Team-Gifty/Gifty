import Foundation
import RealmSwift

class GifticonModel: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var gifticonName: String
    @Persisted var usage: String
    @Persisted var expirationDate: Date
    @Persisted var imageData: Data?
    @Persisted var createdAt: Date = Date()
    
    convenience init(gifticonName: String, usage: String, expirationDate: Date, imageData: Data? = nil) {
        self.init()
        self.gifticonName = gifticonName
        self.usage = usage
        self.expirationDate = expirationDate
        self.imageData = imageData
    }
}
