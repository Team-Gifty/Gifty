//
//  DesignSystem+Widget.swift
//  GiftyWidget
//
//  Created by Claude on 11/27/25.
//

import SwiftUI

// MARK: - Font Extension for SwiftUI
extension Font {
    static func giftyFont(size: CGFloat) -> Font {
        return .custom("Ownglyph_PDH-Rg", size: size)
    }
}

// MARK: - Color Extension for SwiftUI
extension Color {
    static let _6A4C4C = Color("6A4C4C")
    static let FFF7EC = Color("FFF7EC")
}
