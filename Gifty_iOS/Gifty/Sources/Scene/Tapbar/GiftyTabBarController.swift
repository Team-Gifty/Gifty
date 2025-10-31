import UIKit

class GiftyTabBarController: UITabBarController, UITabBarControllerDelegate {

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupTabs()
        setupStyle()
        feedbackGenerator.prepare()
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        feedbackGenerator.impactOccurred()
    }

    private func setupStyle() {
        tabBar.tintColor = ._6_A_4_C_4_C
        tabBar.unselectedItemTintColor = ._6_A_4_C_4_C
    }

    private func setupTabs() {
        let homeVC = MainViewController()
        let addVC = UploadViewController()
        let searchVC = SearchViewController()

        let homeNav = UINavigationController(rootViewController: homeVC)
        let addNav = UINavigationController(rootViewController: addVC)
        let searchNav = UINavigationController(rootViewController: searchVC)
        
        homeNav.setNavigationBarHidden(true, animated: false)
        addNav.setNavigationBarHidden(true, animated: false)
        searchNav.setNavigationBarHidden(true, animated: false)

        homeNav.tabBarItem = GiftyTabBarItem(.home)
        addNav.tabBarItem = GiftyTabBarItem(.add)
        searchNav.tabBarItem = GiftyTabBarItem(.search)

        self.viewControllers = [homeNav, addNav, searchNav]
    }
}

