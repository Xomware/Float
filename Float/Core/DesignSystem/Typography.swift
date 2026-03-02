// Typography.swift
// Float

import SwiftUI

public enum FloatFont {
    public static func largeTitle(_ weight: Font.Weight = .bold) -> Font { .system(.largeTitle, design: .rounded, weight: weight) }
    public static func title(_ weight: Font.Weight = .semibold) -> Font { .system(.title, design: .rounded, weight: weight) }
    public static func title2(_ weight: Font.Weight = .semibold) -> Font { .system(.title2, design: .rounded, weight: weight) }
    public static func headline(_ weight: Font.Weight = .semibold) -> Font { .system(.headline, design: .rounded, weight: weight) }
    public static func body(_ weight: Font.Weight = .regular) -> Font { .system(.body, design: .rounded, weight: weight) }
    public static func callout(_ weight: Font.Weight = .regular) -> Font { .system(.callout, design: .rounded, weight: weight) }
    public static func caption(_ weight: Font.Weight = .medium) -> Font { .system(.caption, design: .rounded, weight: weight) }
    public static func caption2(_ weight: Font.Weight = .regular) -> Font { .system(.caption2, design: .rounded, weight: weight) }
}
