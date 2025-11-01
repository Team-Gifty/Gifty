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
        
        if let appKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String {
            KakaoSDK.initSDK(appKey: appKey)
            print("===== 카카오 SDK 초기화 =====")
            print("✅ 카카오 앱 키: \(appKey)")
            print("============================")
        }
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        NotificationManager.shared.requestAuthorization()
        UNUserNotificationCenter.current().delegate = self
        
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
        
        Messaging.messaging().apnsToken = deviceToken
        
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
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("===== URL 스킴 수신 =====")
        print("URL: \(url.absoluteString)")
        print("Scheme: \(url.scheme ?? "nil")")
        print("Host: \(url.host ?? "nil")")
        print("========================")
        
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        return handleDeepLink(url: url)
    }
    
    private func handleDeepLink(url: URL) -> Bool {
        guard url.scheme == "gifty" else { return false }
        
        print("===== 딥링크 처리 =====")
        print("URL: \(url.absoluteString)")
        
        if url.host == "gift",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let sharedGiftId = components.queryItems?.first(where: { $0.name == "id" })?.value {
            
            print("✅ 공유된 기프티콘 ID: \(sharedGiftId)")
            print("=======================")
            
            receiveSharedGift(sharedGiftId: sharedGiftId)
            return true
        }
        
        if url.host == "gifticon",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let giftId = components.queryItems?.first(where: { $0.name == "id" })?.value {
            
            print("✅ 기프티콘 ID: \(giftId)")
            print("=======================")
            
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
    
    private func receiveSharedGift(sharedGiftId: String) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                return
            }
            
            let loadingAlert = UIAlertController(title: nil, message: "기프티콘을 받는 중...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .medium
            loadingIndicator.startAnimating()
            loadingAlert.view.addSubview(loadingIndicator)
            
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(loadingAlert, animated: true)
            
            FirebaseManager.shared.receiveGift(sharedGiftId: sharedGiftId) { result in
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        switch result {
                        case .success(let gift):
                            let successAlert = UIAlertController(
                                title: "🎁 기프티콘 받기 완료!",
                                message: "\(gift.name)\n\n홈 화면에서 확인하실 수 있습니다.",
                                preferredStyle: .alert
                            )
                            successAlert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                                NotificationCenter.default.post(name: NSNotification.Name("RefreshGiftList"), object: nil)
                            })
                            topController.present(successAlert, animated: true)
                            
                        case .failure(let error):
                            let errorAlert = UIAlertController(
                                title: "기프티콘 받기 실패",
                                message: error.localizedDescription,
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "확인", style: .default))
                            topController.present(errorAlert, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("===== 포그라운드 알림 수신 =====")
        print("알림 제목: \(notification.request.content.title)")
        print("알림 내용: \(notification.request.content.body)")
        print("=============================")
        completionHandler([.list, .banner, .sound])
    }
    
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
