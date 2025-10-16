
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
        let gifts = RealmManager.shared.getGifts(sortedBy: .byExpiryDate)
        
        guard let soonestGift = gifts.first else {
            // No gifts, no notification
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "기프티콘 만료 알림"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: soonestGift.expiryDate)
        let daysRemaining = components.day ?? 0
        
        content.body = "가장 빨리 만료되는 기프티콘의 만료일이 \(daysRemaining)일 남았습니다."
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
        let gifts = RealmManager.shared.getGifts(sortedBy: .byExpiryDate)
        
        guard let soonestGift = gifts.first else {
            // No gifts, no notification
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "기프티콘 만료 알림 (테스트)"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: soonestGift.expiryDate)
        let daysRemaining = components.day ?? 0
        
        content.body = "가장 빨리 만료되는 기프티콘의 만료일이 \(daysRemaining)일 남았습니다."
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
            let realm = try! Realm()
            guard let gift = realm.resolve(giftRef) else {
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "기프티콘 등록 완료"
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: Date(), to: gift.expiryDate)
            let daysRemaining = components.day ?? 0
            
            content.body = "'\(gift.name)' 기프티콘이 등록되었습니다. 만료일까지 \(daysRemaining)일 남았습니다."
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
