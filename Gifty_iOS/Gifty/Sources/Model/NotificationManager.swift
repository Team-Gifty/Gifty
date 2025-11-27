import Foundation
import UserNotifications
import RealmSwift
import Realm

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    print("✅ 알림 권한 허용됨")
                } else {
                    print("❌ 알림 권한 거부됨")
                }
                if let error = error {
                    print("⚠️ 알림 권한 요청 에러: \(error.localizedDescription)")
                }
            }
        )
    }

    func scheduleDailySummaryNotification() {
        let allGifts = RealmManager.shared.getGifts(sortedBy: .byExpiryDate)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let activeGifts = allGifts.filter { gift in
            let expiryDay = calendar.startOfDay(for: gift.expiryDate)
            return expiryDay >= today
        }

        let content = UNMutableNotificationContent()
        content.title = "기프티콘 만료 알림"

        if let soonestGift = activeGifts.first {
            let soonestExpiryDate = soonestGift.expiryDate
            let soonestGifts = activeGifts.filter { Calendar.current.isDate($0.expiryDate, inSameDayAs: soonestExpiryDate) }
            let soonestGiftsCount = soonestGifts.count
            
            let expiryDay = calendar.startOfDay(for: soonestExpiryDate)
            let components = calendar.dateComponents([.day], from: today, to: expiryDay)
            let daysRemaining = components.day ?? 0
            
            if daysRemaining == 0 {
                if soonestGiftsCount > 1 {
                    content.body = "'⚠️ \(soonestGift.name)' 외 \(soonestGiftsCount - 1)개의 교환권이 오늘 만료됩니다!"
                } else {
                    content.body = "'⚠️ \(soonestGift.name)'이(가) 오늘 만료됩니다!"
                }
            } else {
                if soonestGiftsCount > 1 {
                    content.body = "'\(soonestGift.name)' 외 \(soonestGiftsCount - 1)개의 교환권이 \(daysRemaining)일 후에 만료됩니다."
                } else {
                    content.body = "'\(soonestGift.name)'의 만료일이 \(daysRemaining)일 남았습니다."
                }
            }
        } else {
            content.title = "Gifty"
            content.body = "아직 등록된 교환권이 없어요. 지금 바로 등록하고 똑똑하게 관리해보세요!"
        }
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 1

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily_summary_notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily summary notification: \(error)")
            } else {
                print("Daily summary notification scheduled")
            }
        }
    }

    func scheduleDailySummaryNotificationForTest() {
        let allGifts = RealmManager.shared.getGifts(sortedBy: .byExpiryDate)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let activeGifts = allGifts.filter { gift in
            let expiryDay = calendar.startOfDay(for: gift.expiryDate)
            return expiryDay >= today
        }

        let content = UNMutableNotificationContent()
        content.title = "기프티콘 만료 알림 (테스트)"

        if let soonestGift = activeGifts.first {
            let soonestExpiryDate = soonestGift.expiryDate
            let soonestGifts = activeGifts.filter { Calendar.current.isDate($0.expiryDate, inSameDayAs: soonestExpiryDate) }
            let soonestGiftsCount = soonestGifts.count
            
            let expiryDay = calendar.startOfDay(for: soonestExpiryDate)
            let components = calendar.dateComponents([.day], from: today, to: expiryDay)
            let daysRemaining = components.day ?? 0
            
            if daysRemaining == 0 {
                if soonestGiftsCount > 1 {
                    content.body = "'⚠️ \(soonestGift.name)' 외 \(soonestGiftsCount - 1)개의 교환권이 오늘 만료됩니다!"
                } else {
                    content.body = "'⚠️ \(soonestGift.name)'이(가) 오늘 만료됩니다!"
                }
            } else {
                if soonestGiftsCount > 1 {
                    content.body = "'\(soonestGift.name)' 외 \(soonestGiftsCount - 1)개의 교환권이 \(daysRemaining)일 후에 만료됩니다."
                } else {
                    content.body = "'\(soonestGift.name)'의 만료일이 \(daysRemaining)일 남았습니다."
                }
            }
        } else {
            content.title = "Gifty (테스트)"
            content.body = "아직 등록된 교환권이 없어요. 지금 바로 등록하고 똑똑하게 관리해보세요!"
        }
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "daily_summary_notification_test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily summary notification for test: \(error)")
            } else {
                print("Daily summary notification for test scheduled")
            }
        }
    }

    func scheduleImmediateNotification(for gift: Gift) {
        let giftRef = ThreadSafeReference(to: gift)
        DispatchQueue.global().async {
            let realm = RealmManager.shared.realm
            guard let gift = realm.resolve(giftRef) else {
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "기프티콘 등록 완료"

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let expiryDay = calendar.startOfDay(for: gift.expiryDate)
            let components = calendar.dateComponents([.day], from: today, to: expiryDay)
            let daysRemaining = components.day ?? 0

            if daysRemaining == 0 {
                content.body = "'\(gift.name)' 기프티콘이 등록되었습니다. 오늘 만료됩니다!⚠️"
            } else {
                content.body = "'\(gift.name)' 기프티콘이 등록되었습니다. 만료일까지 \(daysRemaining)일 남았습니다."
            }
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

            let request = UNNotificationRequest(identifier: "\(gift.id.stringValue)_immediate", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling immediate notification: \(error)")
                }
            }
        }
    }
}
