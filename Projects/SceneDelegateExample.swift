// SceneDelegate.swift 수정 예시
// 기존 SceneDelegate의 scene(_:willConnectTo:options:) 메서드를 아래와 같이 수정하세요

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // JWT 토큰이 있으면 메인 화면, 없으면 로그인 화면
        let rootVC: UIViewController
        if JwtStore.shared.hasValidToken {
            rootVC = GiftyTabBarController()
        } else {
            let loginVC = DIContainer.shared.makeLoginViewController()
            rootVC = UINavigationController(rootViewController: loginVC)
        }

        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }

    // 기존 다른 메서드들은 그대로 유지...
}
