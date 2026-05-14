// BrandConstants.swift
// BluePond Wellness

import UIKit

// MARK: - UIColor Hex Extension

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red   = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8)  / 255.0
        let blue  = CGFloat(rgb & 0x0000FF)          / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - Brand Colors

struct BrandColors {
    /// Deep Navy #00172C — primary background
    static let deepNavy    = UIColor(hex: "#00172C")
    /// Navy Card #001E3C — card/surface background
    static let navyCard    = UIColor(hex: "#001E3C")
    /// Accent Blue #005CFF — primary CTA, selected states
    static let accentBlue  = UIColor(hex: "#005CFF")
    /// Accent Blue 2 #1A6FFF — lighter variant for gradients
    static let accentBlue2 = UIColor(hex: "#1A6FFF")
    /// Teal #00BFA5 — points, positive indicators
    static let teal        = UIColor(hex: "#00BFA5")
    /// Amber #FFB300 — streak, warnings
    static let amber       = UIColor(hex: "#FFB300")
    /// Error Red #FF3B30 — error states
    static let errorRed    = UIColor(hex: "#FF3B30")
    /// White — primary text on dark backgrounds
    static let white       = UIColor.white
    /// Steel Blue #7FB3D3 — subtitle text on dark backgrounds
    static let steelBlue   = UIColor(hex: "#7FB3D3")
    /// Muted Blue #4A7FA5 — unselected tab icons, secondary text
    static let mutedBlue   = UIColor(hex: "#4A7FA5")
}

// MARK: - Brand Fonts

struct BrandFonts {
    static func heading(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func body(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func label(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func semibold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func light(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }
}
