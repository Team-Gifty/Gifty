import UIKit

enum FontType {
    case ongulipParkDahyeon
    case ongulipConcon
    case gumiRomance
    case memomentKkukkkuk

    var name: String {
        switch self {
        case .ongulipParkDahyeon:
            return "온글잎 박다현체"
        case .ongulipConcon:
            return "온글잎 콘콘체"
        case .gumiRomance:
            return "Gumi Romance"
        case .memomentKkukkkuk:
            return "memomentKkukkkuk"
        }
    }
}

extension UIFont {
    static func customFont(type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: type.name, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
