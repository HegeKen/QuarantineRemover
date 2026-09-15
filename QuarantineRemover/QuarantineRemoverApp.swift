import SwiftUI

@main
struct QuarantineRemoverApp: App {
    // 主题选择持久化在 UserDefaults 中，默认跟随系统
    @AppStorage("appTheme") private var themeRaw: String = AppTheme.system.rawValue

    private var theme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // 切换主题时即时生效；当选择 .system 时返回 nil，
                // 由 SwiftUI 自动跟随 macOS 系统外观切换。
                .preferredColorScheme(theme.preferredColorScheme)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
