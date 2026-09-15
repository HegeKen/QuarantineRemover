import SwiftUI

struct AppListView: View {
    @ObservedObject var model: AppModel
    @State private var searchText = ""
    
    var filteredApps: [AppModel.AppInfo] {
        if searchText.isEmpty {
            return model.installedApps
        } else {
            return model.installedApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("搜索应用...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.primary)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(12)
            .liquidGlassCard()
            .padding(.horizontal)
            .padding(.top)
            
            // 应用列表：自适应网格，列数随窗口宽度变化
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 110, maximum: 160), spacing: 10)],
                    spacing: 12
                ) {
                    ForEach(filteredApps) { app in
                        AppGridItemView(app: app, isSelected: model.selectedApps.contains(app.path)) {
                            model.toggleSelection(appPath: app.path)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
        }
    }
}

/// 应用图标内存缓存。
/// NSCache 本身线程安全，无需额外加锁即可在后台线程读写，
/// 避免网格滚动时反复解析同一图标。
final class AppIconCache {
    static let shared = AppIconCache()
    private let cache = NSCache<NSString, NSImage>()

    private init() {
        cache.countLimit = 512
    }

    func icon(for path: String) -> NSImage? {
        cache.object(forKey: path as NSString)
    }

    func store(_ icon: NSImage, for path: String) {
        cache.setObject(icon, forKey: path as NSString)
    }
}

/// 网格单元：图标在上、名称在下，点击即切换选中状态。
struct AppGridItemView: View {
    let app: AppModel.AppInfo
    let isSelected: Bool
    let action: () -> Void
    @State private var icon: NSImage?
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme

    private static let iconSize: CGFloat = 60

    /// 未选中单元的填充/描边基色，随明暗模式取反以保证对比度
    private var itemTint: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 应用图标
                Group {
                    if let icon = icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "app")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: Self.iconSize, height: Self.iconSize)

                // 应用名称
                Text(app.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 28, alignment: .top)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? Color.blue.opacity(0.6) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help(app.path)
        // 图标按需懒加载：单元进入可视区后才在后台解析图标，
        // 优先命中内存缓存，避免滚动时重复解析阻塞主线程。
        .task(id: app.path) {
            // 已有图标（来自拖放场景）则直接使用
            if let existing = app.icon {
                self.icon = existing
                return
            }
            if let cached = AppIconCache.shared.icon(for: app.path) {
                self.icon = cached
                return
            }
            let loaded = await Task.detached(priority: .userInitiated) {
                let image = NSWorkspace.shared.icon(forFile: app.path)
                image.size = NSSize(width: 128, height: 128)
                return image
            }.value
            AppIconCache.shared.store(loaded, for: app.path)
            self.icon = loaded
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.22)
        }
        return isHovering ? itemTint.opacity(0.10) : itemTint.opacity(0.05)
    }
}
