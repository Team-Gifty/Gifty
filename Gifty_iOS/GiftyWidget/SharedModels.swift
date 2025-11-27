//
//  SharedModels.swift
//  GiftyWidget
//
//  Created by Claude on 11/27/25.
//

import Foundation
import RealmSwift

// SortOrder enum (위젯에서 사용)
enum SortOrder {
    case byExpiryDate
    case byRegistrationDate
}

// Gift 모델 (위젯에서 읽기 전용으로 사용)
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

// User 모델 (위젯에서 읽기 전용으로 사용)
class User: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var nickname: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var gifts: List<Gift>
}

// RealmManager (위젯용 간소화 버전)
class RealmManager {
    static let shared = RealmManager()

    // App Group identifier
    private let appGroupIdentifier = "group.com.ahyeonlee.gifty.shared"

    var realm: Realm {
        do {
            let config = Realm.Configuration(
                fileURL: getRealmFileURL(),
                schemaVersion: 4,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 3 {
                        migration.enumerateObjects(ofType: "Gift") { oldObject, newObject in
                            newObject?["isExpired"] = false
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
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let realmURL = containerURL.appendingPathComponent("default.realm")
            print("📁 위젯 Realm 경로 (App Group): \(realmURL.path)")
            return realmURL
        } else {
            print("⚠️ App Group 컨테이너를 찾을 수 없습니다. 기본 경로를 사용합니다.")
            let defaultURL = Realm.Configuration.defaultConfiguration.fileURL
            print("📁 위젯 Realm 경로 (기본): \(defaultURL?.path ?? "nil")")
            return defaultURL
        }
    }

    // 위젯에서 사용할 간단한 메서드
    func getGifts(sortedBy sortOrder: SortOrder = .byRegistrationDate) -> Results<Gift> {
        switch sortOrder {
        case .byRegistrationDate:
            return realm.objects(Gift.self).sorted(byKeyPath: "id", ascending: false)
        case .byExpiryDate:
            return realm.objects(Gift.self).sorted(byKeyPath: "expiryDate", ascending: true)
        }
    }
}
