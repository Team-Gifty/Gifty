import UIKit

extension UIViewController {
    func hideTabBar() {
        self.tabBarController?.tabBar.isHidden = true
    }
    func showTabBar() {
        self.tabBarController?.tabBar.isHidden = false
    }
    var hidesTabBarWhenPushed: Bool {
        get {
            return self.hidesBottomBarWhenPushed
        }
        set {
            self.hidesBottomBarWhenPushed = newValue
        }
    }
}
