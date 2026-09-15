import SwiftUI

/// 应用主题选项。
/// 通过 `@AppStorage("appTheme")` 持久化用户选择，键值为 `AppTheme.rawValue`。
enum AppTheme: String, CaseIterable {
    /// 跟随系统外观（macOS 系统设置中的浅色/深色）
    case system
    /// 强制浅色
    case light
    /// 强制深色
    case dark

    /// 显示名称
    var label: String {
        switch self {
        case .system: return "跟随系统"
        case .light:  return "浅色"
        case .dark:   return "深色"
        }
    }

    /// SF Symbol 图标
    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max"
        case .dark:   return "moon"
        }
    }

    /// 返回需要应用到 `.preferredColorScheme(_:)` 的值。
    /// 返回 `nil` 表示让 SwiftUI 跟随系统外观。
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
