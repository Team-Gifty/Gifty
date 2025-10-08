import UIKit

class GiftyTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
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

