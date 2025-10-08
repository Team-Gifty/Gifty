import Foundation
import RealmSwift

class MainViewModel {
    var gifts: Results<Gift> {
        return RealmManager.shared.getGifts()
    }
    
    func deleteGift(gift: Gift) {
        RealmManager.shared.deleteGift(gift)
    }
}