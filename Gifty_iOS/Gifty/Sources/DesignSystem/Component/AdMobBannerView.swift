import UIKit
import GoogleMobileAds

final class AdMobBannerView: UIView {

    // MARK: - Properties
    private let adUnitID: String
    private var bannerView: BannerView?

    // MARK: - Initialization
    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init(frame: .zero)
        setupBannerView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupBannerView() {
        bannerView = BannerView(adSize: AdSizeBanner)
        guard let bannerView = bannerView else { return }

        bannerView.adUnitID = adUnitID
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: AdSizeBanner.size.height)
        ])
    }

    // MARK: - Public Methods
    func loadAd(from viewController: UIViewController) {
        bannerView?.rootViewController = viewController
        bannerView?.load(Request())
        print("===== AdMob 배너 광고 로드 =====")
        print("✅ 광고 단위 ID: \(adUnitID)")
        print("==============================")
    }
}
