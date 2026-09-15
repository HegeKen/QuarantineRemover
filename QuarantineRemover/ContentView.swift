import SwiftUI

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var isDropZoneHovering = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    // 与根 App 共享同一个 UserDefaults 键，主题切换实时生效
    @AppStorage("appTheme") private var themeRaw: String = AppTheme.system.rawValue

    private var theme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .system
    }

    var body: some View {
        ZStack {
            // Liquid Glass 背景
            LiquidGlassBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 标题栏
                headerView

                // 主内容区域
                HStack(spacing: 20) {
                    // 左侧：拖放区域和已选择的应用
                    VStack(spacing: 16) {
                        // 拖放区域
                        DropZoneView(isHovering: $isDropZoneHovering) { urls in
                            for url in urls {
                                if url.pathExtension == "app" {
                                    model.addDroppedApp(url: url)
                                }
                            }
                        }

                        // 已拖放的应用列表
                        if !model.droppedApps.isEmpty {
                            droppedAppsSection
                        }
                    }
                    .frame(width: 300)
                    // 撑满主内容区高度，与右侧 App List 面板上下对齐
                    .frame(maxHeight: .infinity, alignment: .top)

                    // 右侧：已安装应用列表
                    VStack(spacing: 0) {
                        Text("已安装的应用")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)

                        AppListView(model: model)
                    }
                    .liquidGlassCard()
                }
                .padding()

                // 底部操作栏
                bottomActionBar
            }
        }
        .alert("处理结果", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("隔离属性移除工具")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("移除 macOS 应用的隔离属性 (com.apple.quarantine)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 状态指示器
            if model.isProcessing {
                ProgressView()
                    .scaleEffect(0.8)
                Text("处理中...")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            // 主题切换控件
            Menu {
                // 使用 inline Picker，当前选中项前会显示系统标准勾选标记
                Picker("主题", selection: $themeRaw) {
                    ForEach(AppTheme.allCases, id: \.self) { option in
                        Label(option.label, systemImage: option.iconName)
                            .tag(option.rawValue)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Label {
                    Text(theme.label)
                } icon: {
                    Image(systemName: theme.iconName)
                }
                .labelStyle(.iconOnly)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 32, height: 32)
                .background(
                    Circle().fill(Color.primary.opacity(0.08))
                )
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help("主题：\(theme.label)")
            .accessibilityLabel("主题切换")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
        .padding()
    }

    private var droppedAppsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("已选择的应用")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    model.clearDroppedApps()
                }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(model.droppedApps) { app in
                        HStack(spacing: 8) {
                            if let icon = app.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }

                            Text(app.name)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Spacer()

                            Button(action: {
                                model.selectedApps.remove(app.path)
                                model.droppedApps.removeAll { $0.id == app.id }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.blue.opacity(0.2))
                        )
                    }
                }
            }
            .frame(maxHeight: 150)
        }
        .padding()
        .liquidGlassCard()
    }

    private var bottomActionBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("已选择 \(model.selectedApps.count) 个应用")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !model.statusMessage.isEmpty {
                    Text(model.statusMessage)
                        .font(.caption)
                        .foregroundColor(model.showSuccess ? .green : .orange)
                }
            }

            Spacer()

            Button(action: {
                if model.selectedApps.isEmpty {
                    alertMessage = "请先选择要处理的应用"
                    showAlert = true
                    return
                }

                model.removeQuarantine { success, message in
                    alertMessage = message
                    showAlert = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.slash")
                    Text("移除隔离属性")
                }
                .liquidGlassButton(isPrimary: true)
            }
            .disabled(model.isProcessing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
        .padding()
    }
}

#Preview {
    ContentView()
}
