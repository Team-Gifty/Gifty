import UIKit
import GoogleMobileAds

final class AdMobBannerView: UIView {

    private let adUnitID: String
    private var bannerView: BannerView?

    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init(frame: .zero)
        backgroundColor = .systemGray6
        setupBannerView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBannerView() {
        bannerView = BannerView(adSize: AdSizeBanner)
        guard let bannerView = bannerView else { return }

        bannerView.adUnitID = adUnitID
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.delegate = self

        addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: AdSizeBanner.size.width),
            bannerView.heightAnchor.constraint(equalToConstant: AdSizeBanner.size.height)
        ])

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: AdSizeBanner.size.height)
        ])
    }

    func loadAd(from viewController: UIViewController) {
        bannerView?.rootViewController = viewController
        let request = Request()
        bannerView?.load(request)
        print("===== AdMob 배너 광고 로드 시작 =====")
        print("✅ 광고 단위 ID: \(adUnitID)")
        print("✅ Root ViewController: \(viewController)")
        print("====================================")
    }
}

extension AdMobBannerView: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("===== AdMob 배너 광고 수신 성공 =====")
        print("✅ 광고가 성공적으로 로드되었습니다")
        print("===================================")
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("===== AdMob 배너 광고 로드 실패 =====")
        print("❌ 에러: \(error.localizedDescription)")
        print("===================================")
    }
}
