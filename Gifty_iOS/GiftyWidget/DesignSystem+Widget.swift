import SwiftUI

struct AppFontName {
    static let giftyFont = "Ownglyph_PDH-Rg"
    static let cellFont = "Ownglyph_corncorn-Rg"
}

extension Font {
    static func giftyFont(size: CGFloat) -> Font {
        return .custom(AppFontName.giftyFont, size: size)
    }

    static func cellFont(size: CGFloat) -> Font {
        return .custom(AppFontName.cellFont, size: size)
    }
}

extension Color {
    // Hex 색상 초기화
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // 미리 정의된 색상
    static let widgetBackground = Color(hex: "FFF7EC")
    static let widgetText = Color(hex: "6A4C4C")
}
