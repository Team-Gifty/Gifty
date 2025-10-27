import UIKit
import RealmSwift

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
        
        window?.rootViewController = OnboardingViewController()
        window?.makeKeyAndVisible()
        printRealmPath()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let rootVC: UIViewController
            if RealmManager.shared.getUser() != nil {
                rootVC = GiftyTabBarController()
            } else {
                rootVC = NicknameViewController()
            }
            
            let navController = UINavigationController(rootViewController: rootVC)
            
            guard let window = self.window else { return }
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navController
            }, completion: nil)
        }
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

