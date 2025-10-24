
import Foundation

class NicknameViewModel {
    func saveNickname(nickname: String) {
        RealmManager.shared.saveNickname(nickname)
    }

    func getSavedNickname() -> String? {
        return RealmManager.shared.getUser()?.nickname
    }

    func deleteNickname() {
        RealmManager.shared.deleteUser()
    }
}
