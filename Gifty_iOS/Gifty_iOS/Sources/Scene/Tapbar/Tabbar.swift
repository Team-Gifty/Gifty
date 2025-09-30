import UIKit


class Tabbar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = HomeVC()
        let add = AddVC()
        let search = SearchVC()
        
        home.tabBarItem = UITabBarItem(title: nil, image: UIImage.home, tag: 0)
        add.tabBarItem = UITabBarItem(title: nil, image: UIImage.plus, tag: 1)
        search.tabBarItem = UITabBarItem(title: nil, image: UIImage.search, tag: 2)
        
        viewControllers = [
            UINavigationController(rootViewController: home),
            UINavigationController(rootViewController: add),
            UINavigationController(rootViewController: search)
        ]
        
    }
}
