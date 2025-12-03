import UIKit
// import GoogleMobileAds // 임시 비활성화

class GiftyTabBarController: UITabBarController, UITabBarControllerDelegate {

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    // 광고 임시 비활성화
//    private lazy var adMobBannerView: AdMobBannerView = {
//        #if DEBUG
//        let adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        #else
//        let adUnitID = Bundle.main.infoDictionary?["ADMOB_BANNER_AD_UNIT_ID"] as? String ?? "ca-app-pub-6956983354882052/3641173207"
//        #endif
//        return AdMobBannerView(adUnitID: adUnitID)
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupTabs()
        setupStyle()
//        setupAdMobBanner() // 광고 임시 비활성화
        feedbackGenerator.prepare()
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        feedbackGenerator.impactOccurred()
    }

    private func setupStyle() {
        tabBar.tintColor = ._6_A_4_C_4_C
        tabBar.unselectedItemTintColor = ._6_A_4_C_4_C
    }

    // 광고 임시 비활성화
//    private func setupAdMobBanner() {
//        view.addSubview(adMobBannerView)
//        adMobBannerView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            adMobBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            adMobBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            adMobBannerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
//        ])
//
//        adMobBannerView.loadAd(from: self)
//    }

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

