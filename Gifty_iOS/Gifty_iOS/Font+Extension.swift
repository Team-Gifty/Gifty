import UIKit

enum FontType {
    case ongulipParkDahyeon
    case ongulipConcon
    case gumiRomance
    case memomentKkukkkuk

    var name: String {
        switch self {
        case .ongulipParkDahyeon:
            return "giftyFont"
        case .ongulipConcon:
            return "cellFont"
        case .gumiRomance:
            return "nicknameFont"
        case .memomentKkukkkuk:
            return "onboardingFont"
        }
    }
}

extension UIFont {
    static func customFont(type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: type.name, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
