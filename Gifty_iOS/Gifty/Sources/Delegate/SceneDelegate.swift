import UIKit
import RealmSwift
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func printRealmPath() {
        if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {
            print("📂 Realm file path: \(fileURL.path)")
        } else {
            print("⚠️ Realm file URL not found.")
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let rootVC: UIViewController
        if RealmManager.shared.getUser() != nil {
            rootVC = GiftyTabBarController()
        } else {
            rootVC = NicknameViewController()
        }
        
        let navController = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        printRealmPath()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {
        checkAndUpdateExpiredGifts()
    }
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {
        checkAndUpdateExpiredGifts()
    }
    func sceneDidEnterBackground(_ scene: UIScene) {}
    
    // URL 스킴 처리 (iOS 13+)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            print("===== SceneDelegate URL 수신 =====")
            print("URL: \(url.absoluteString)")
            print("Scheme: \(url.scheme ?? "nil")")
            print("Host: \(url.host ?? "nil")")
            print("=================================")
            
            // 카카오톡 인증 처리
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
            
            // 딥링크 처리
            handleDeepLink(url: url)
        }
    }
    
    // 딥링크 처리 함수
    private func handleDeepLink(url: URL) {
        guard url.scheme == "gifty" else { return }
        
        print("===== 딥링크 처리 =====")
        print("URL: \(url.absoluteString)")
        
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
        } else {
            print("❌ 올바르지 않은 딥링크 형식")
            print("=======================")
        }
    }
    private func checkAndUpdateExpiredGifts() {
        let gifts = RealmManager.shared.getGifts()
        
        try? RealmManager.shared.realm.write {
            for gift in gifts {
                if gift.checkIsExpired && !gift.isExpired {
                    gift.isExpired = true
                    print("🗓️ 만료 처리: \(gift.name)")
                }
            }
        }
    }
}

