import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // 파이어베이스 Messaging 설정
        Messaging.messaging().delegate = self
        
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                print("===== 알림 권한 =====")
                if granted {
                    print("✅ 알림 권한 허용됨")
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    print("❌ 알림 권한 거부됨")
                }
                if let error = error {
                    print("⚠️ 알림 권한 요청 에러: \(error.localizedDescription)")
                }
                print("===================")
            }
        )
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("===== APNS 토큰 정보 =====")
        print("✅ APNS 토큰 등록 성공")
        print("APNS Token: \(token)")
        print("========================")
        
        // APNS 토큰을 FCM에 전달
        Messaging.messaging().apnsToken = deviceToken
        
        // APNS 토큰 설정 후 FCM 토큰 가져오기
        Messaging.messaging().token { token, error in
            print("===== FCM 토큰 강제 조회 =====")
            if let error = error {
                print("❌ FCM 토큰 가져오기 실패: \(error.localizedDescription)")
            } else if let token = token {
                print("✅ FCM 토큰: \(token)")
            } else {
                print("⚠️ FCM 토큰이 아직 생성되지 않았습니다")
            }
            print("============================")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("===== APNS 토큰 에러 =====")
        print("❌ APNS 토큰 등록 실패: \(error.localizedDescription)")
        print("에러 상세: \(error)")
        print("========================")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("===== 포그라운드 알림 수신 =====")
        print("알림 제목: \(notification.request.content.title)")
        print("알림 내용: \(notification.request.content.body)")
        print("=============================")
        completionHandler([.list, .banner, .sound])
    }
    
    // 알림 탭했을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("===== 알림 탭됨 =====")
        print("알림 제목: \(response.notification.request.content.title)")
        print("알림 내용: \(response.notification.request.content.body)")
        print("===================")
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    
    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("===== FCM 토큰 정보 (Delegate) =====")
        if let fcmToken = fcmToken {
            print("✅ FCM 토큰 발급 성공")
            print("FCM Token: \(fcmToken)")
        } else {
            print("❌ FCM 토큰이 nil입니다")
        }
        print("==================================")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}
