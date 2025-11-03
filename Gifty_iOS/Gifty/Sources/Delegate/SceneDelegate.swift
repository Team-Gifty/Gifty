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
            let nicknameVC = NicknameViewController()
            rootVC = UINavigationController(rootViewController: nicknameVC)
        }
        
        window?.rootViewController = rootVC
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
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            print("===== SceneDelegate URL 수신 =====")
            print("URL: \(url.absoluteString)")
            print("Scheme: \(url.scheme ?? "nil")")
            print("Host: \(url.host ?? "nil")")
            print("=================================")
            
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
                return
            }
            
            handleDeepLink(url: url)
        }
    }
    
    private func handleDeepLink(url: URL) {
        print("===== 딥링크 처리 =====")
        print("URL: \(url.absoluteString)")
        print("Scheme: \(url.scheme ?? "nil")")
        print("Host: \(url.host ?? "nil")")
        
        if url.scheme == "kakaolink" || url.host?.contains("kakao") == true {
            print("🟡 카카오톡 딥링크 감지")
            
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                print("🔍 파라미터: \(components.queryItems ?? [])")
                
                if let path = components.queryItems?.first(where: { $0.name == "path" })?.value,
                   path == "gift",
                   let sharedGiftId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                    print("✅ 공유된 기프티콘 ID: \(sharedGiftId)")
                    print("=======================")
                    receiveSharedGift(sharedGiftId: sharedGiftId)
                    return
                }
            }
        }
        
        if url.scheme == "gifty" {
            print("🔗 Gifty 딥링크 감지")
            
            if url.host == "gift",
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let sharedGiftId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                
                print("✅ 공유된 기프티콘 ID: \(sharedGiftId)")
                print("=======================")
                receiveSharedGift(sharedGiftId: sharedGiftId)
                return
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
                return
            }
        }
        
        print("❌ 올바르지 않은 딥링크 형식")
        print("=======================")
    }
    
    private func receiveSharedGift(sharedGiftId: String) {
        guard let rootViewController = window?.rootViewController else { return }
        
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

        SupabaseManager.shared.receiveGift(sharedGiftId: sharedGiftId) { result in
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
