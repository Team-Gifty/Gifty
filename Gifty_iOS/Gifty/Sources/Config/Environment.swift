import Foundation

enum BuildEnvironment: String {
    case debug = "DEBUG"
    case stage = "STAGE"
    case production = "PRODUCTION"

    static var current: BuildEnvironment {
        #if DEBUG
        return .debug
        #elseif STAGE
        return .stage
        #else
        return .production
        #endif
    }
}

struct AdMobConfig {
    static var appID: String {
        switch BuildEnvironment.current {
        case .debug, .stage:
            // Google AdMob Test App ID
            return "ca-app-pub-3940256099942544~1458002511"
        case .production:
            // 실제 AdMob App ID
            return "ca-app-pub-6956983354882052~4032324948"
        }
    }

    static var bannerID: String {
        switch BuildEnvironment.current {
        case .debug, .stage:
            // Google AdMob Test Banner ID
            return "ca-app-pub-3940256099942544/2934735716"
        case .production:
            // 실제 Banner Unit ID (AdMob 콘솔에서 생성 필요)
            return "ca-app-pub-6956983354882052/YOUR_BANNER_UNIT_ID"
        }
    }

    static var interstitialID: String {
        switch BuildEnvironment.current {
        case .debug, .stage:
            // Google AdMob Test Interstitial ID
            return "ca-app-pub-3940256099942544/4411468910"
        case .production:
            // 실제 Interstitial Unit ID (AdMob 콘솔에서 생성 필요)
            return "ca-app-pub-6956983354882052/YOUR_INTERSTITIAL_UNIT_ID"
        }
    }

    static var isTestMode: Bool {
        BuildEnvironment.current != .production
    }
}

// 사용 예시:
// print("현재 환경: \(BuildEnvironment.current.rawValue)")
// print("AdMob App ID: \(AdMobConfig.appID)")
// print("테스트 모드: \(AdMobConfig.isTestMode)")
