import Foundation

class UploadViewModel {
    func saveGift(name: String, usage: String, expiryDate: Date, memo: String?, imagePath: String) -> Gift? {
        return RealmManager.shared.saveGift(name: name, usage: usage, expiryDate: expiryDate, memo: memo, imagePath: imagePath)
    }
}