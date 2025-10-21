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

        homeVC.tabBarItem = GiftyTabBarItem(.home)
        addVC.tabBarItem = GiftyTabBarItem(.add)
        searchVC.tabBarItem = GiftyTabBarItem(.search)

        self.viewControllers = [homeVC, addVC, searchVC]
    }
}

