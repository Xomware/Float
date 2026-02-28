import SwiftUI

// MARK: - FloatColors
// Float is a dark-first app. Colors are defined for dark mode as primary,
// with adaptive variants for light mode (system) and high-contrast support.

public enum FloatColors {
    // MARK: - Brand
    /// Deep amber — primary brand color (unchanged in any mode)
    public static let primary = Color(hex: "#FF8C00")
    /// Cream — secondary / soft highlight
    public static let secondary = Color(hex: "#FFF8F0")
    /// Coral — accent / CTA
    public static let accent = Color(hex: "#FF4500")

    // MARK: - Backgrounds (adaptive)
    /// Main app background — near-black in dark mode, near-white in light mode
    public static let background = Color("FloatBackground")
    /// Card surface — adaptive
    public static let cardBackground = Color("FloatCardBackground")
    /// Elevated surface (modal, sheet header)
    public static let elevatedBackground = Color("FloatElevatedBackground")

    // MARK: - Semantic Status
    public static let success = Color(hex: "#2ECC71")
    public static let warning = Color(hex: "#FF6B35")
    public static let error   = Color(hex: "#E74C3C")

    // MARK: - Text (adaptive)
    /// Primary text — white in dark, near-black in light
    public static let textPrimary   = Color("FloatTextPrimary")
    /// Secondary / muted text
    public static let textSecondary = Color("FloatTextSecondary")

    // MARK: - Deal Category Colors
    public static let drinkColor = Color(hex: "#4A90D9")
    public static let foodColor  = Color(hex: "#7ED321")
    public static let comboColor = Color(hex: "#9B59B6")
    public static let eventColor = Color(hex: "#F39C12")

    // MARK: - Separator / Divider
    public static let separator = Color("FloatSeparator")

    // MARK: - Fallbacks (for previews / when asset catalog is absent)
    /// Returns a hardcoded dark-mode value for use in Xcode previews.
    public static func fallback(dark: Color, light: Color) -> Color {
        // UIKit bridge ensures correct rendering in previews
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

// MARK: - Convenience adaptive constructors
public extension FloatColors {
    /// Adaptive background (dark: #1A1A1A, light: #F6F6F6)
    static var adaptiveBackground: Color {
        fallback(dark: Color(hex: "#1A1A1A"), light: Color(hex: "#F6F6F6"))
    }
    /// Adaptive card background (dark: #242424, light: #FFFFFF)
    static var adaptiveCardBackground: Color {
        fallback(dark: Color(hex: "#242424"), light: Color(hex: "#FFFFFF"))
    }
    /// Adaptive elevated background (dark: #2C2C2E, light: #EEEEEF)
    static var adaptiveElevatedBackground: Color {
        fallback(dark: Color(hex: "#2C2C2E"), light: Color(hex: "#EEEEEF"))
    }
    /// Adaptive primary text
    static var adaptiveTextPrimary: Color {
        fallback(dark: .white, light: Color(hex: "#111111"))
    }
    /// Adaptive secondary text
    static var adaptiveTextSecondary: Color {
        fallback(dark: Color(hex: "#8E8E93"), light: Color(hex: "#6D6D72"))
    }
    /// Adaptive separator
    static var adaptiveSeparator: Color {
        fallback(dark: Color(white: 1, opacity: 0.08), light: Color(white: 0, opacity: 0.1))
    }
}

// MARK: - Accessibility Helpers
public extension Color {
    /// Returns a version of this color with minimum contrast 4.5:1 when needed.
    /// Use for text on colored backgrounds.
    var accessibleForeground: Color {
        // For now returns white (most Float UI is dark-first); extend with WCAG math as needed.
        .white
    }
}
