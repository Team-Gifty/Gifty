
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
    
    func scheduleNotifications() {
        let gifts = RealmManager.shared.getGifts()
        
        for gift in gifts {
            let giftRef = ThreadSafeReference(to: gift)
            DispatchQueue.global().async {
                let realm = try! Realm()
                guard let gift = realm.resolve(giftRef) else {
                    return
                }
                
                let expiryDate = gift.expiryDate
                let calendar = Calendar.current
                let intervals = [3, 7, 14, 30]
                
                for interval in intervals {
                    let notificationDate = calendar.date(byAdding: .day, value: -interval, to: expiryDate)
                    
                    if let notificationDate = notificationDate, calendar.isDateInToday(notificationDate) {
                        let content = UNMutableNotificationContent()
                        content.title = "기프티콘 만료 알림"
                        content.body = "'\(gift.name)' 기프티콘이 \(interval)일 후에 만료됩니다."
                        content.sound = .default
                        
                        var dateComponents = calendar.dateComponents([.year, .month, .day], from: notificationDate)
                        dateComponents.hour = 12
                        dateComponents.minute = 00
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                        
                        let request = UNNotificationRequest(identifier: "\(gift.id.stringValue)_\(interval)days", content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                print("Error scheduling notification: \(error)")
                            }
                        }
                    }
                }
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
