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
        
        let rootVC: UIViewController

        if RealmManager.shared.getUser() != nil {
            rootVC = GiftyTabBarController()
        } else {
            rootVC = NicknameViewController()
        }
        printRealmPath()

        let navController = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

