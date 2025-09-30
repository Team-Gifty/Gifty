import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    private var realm: Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    private init() {}
    
    // MARK: - Nickname 저장
    func saveNickname(_ nickname: String) {
        do {
            try realm.write {
                // 기존 유저 데이터 삭제 (최신 닉네임만 유지)
                let allUsers = realm.objects(UserModel.self)
                realm.delete(allUsers)
                
                // 새로운 닉네임 저장
                let user = UserModel(nickname: nickname)
                realm.add(user)
            }
            print("✅ 닉네임 저장 성공: \(nickname)")
        } catch {
            print("❌ 닉네임 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Nickname 읽기
    func getNickname() -> String? {
        let users = realm.objects(UserModel.self).sorted(byKeyPath: "createdAt", ascending: false)
        return users.first?.nickname
    }
    
    // MARK: - Nickname 삭제
    func deleteNickname() {
        do {
            try realm.write {
                let allUsers = realm.objects(UserModel.self)
                realm.delete(allUsers)
            }
            print("✅ 닉네임 삭제 성공")
        } catch {
            print("❌ 닉네임 삭제 실패: \(error.localizedDescription)")
        }
    }
}
