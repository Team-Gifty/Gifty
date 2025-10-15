import UIKit

class GiftyTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupStyle()
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

