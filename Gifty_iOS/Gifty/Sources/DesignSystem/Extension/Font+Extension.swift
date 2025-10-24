import UIKit

struct AppFontName {
    static let giftyFont = "Ownglyph_PDH-Rg"
    static let cellFont = "Ownglyph_corncorn-Rg"
    static let nicknameFont = "GumiRomanceTTF"
    static let onboardingFont = "MemomentKkukkukkR"
}

extension UIFont {
    static func giftyFont(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.giftyFont, size: size) ?? .systemFont(ofSize: size)
    }
    
    static func cellFont(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.cellFont, size: size) ?? .systemFont(ofSize: size)
    }
    
    static func nicknameFont(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.nicknameFont, size: size) ?? .systemFont(ofSize: size)
    }
    
    static func onboardingFont(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.onboardingFont, size: size) ?? .systemFont(ofSize: size)
    }
}