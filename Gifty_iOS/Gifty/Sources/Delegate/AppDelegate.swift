import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import KakaoSDKCommon
import KakaoSDKAuth

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 카카오 SDK 초기화
        if let appKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String {
            KakaoSDK.initSDK(appKey: appKey)
            print("===== 카카오 SDK 초기화 =====")
            print("✅ 카카오 앱 키: \(appKey)")
            print("============================")
        }
        
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // 파이어베이스 Messaging 설정
        Messaging.messaging().delegate = self
        
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        NotificationManager.shared.requestAuthorization()
        UNUserNotificationCenter.current().delegate = self
        
        // 예약된 알림 확인
        NotificationManager.shared.scheduleDailySummaryNotification()
        
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
    
    // URL 스킴 처리 (iOS 13 미만 지원)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("===== URL 스킴 수신 =====")
        print("URL: \(url.absoluteString)")
        print("Scheme: \(url.scheme ?? "nil")")
        print("Host: \(url.host ?? "nil")")
        print("========================")
        
        // 카카오톡 인증 처리
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        // 딥링크 처리
        return handleDeepLink(url: url)
    }
    
    // 딥링크 처리 함수
    private func handleDeepLink(url: URL) -> Bool {
        guard url.scheme == "gifty" else { return false }
        
        print("===== 딥링크 처리 =====")
        print("URL: \(url.absoluteString)")
        
        // gifty://gifticon?id=123 형태로 받기
        if url.host == "gifticon",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let giftId = components.queryItems?.first(where: { $0.name == "id" })?.value {
            
            print("✅ 기프티콘 ID: \(giftId)")
            print("=======================")
            
            // MainViewController로 이동 후 해당 기프티콘 표시
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenGifticon"),
                object: nil,
                userInfo: ["giftId": giftId]
            )
            return true
        }
        
        print("❌ 올바르지 않은 딥링크 형식")
        print("=======================")
        return false
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
