import SwiftUI

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var isDropZoneHovering = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                    
                    // 右侧：已安装应用列表
                    VStack(spacing: 0) {
                        Text("已安装的应用")
                            .font(.headline)
                            .foregroundColor(.white)
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
                    .foregroundColor(.white)
                
                Text("移除 macOS 应用的隔离属性 (com.apple.quarantine)")
                    .font(.caption)
                    .foregroundColor(.gray)
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
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .padding()
    }
    
    private var droppedAppsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("已选择的应用")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
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
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                model.selectedApps.remove(app.path)
                                model.droppedApps.removeAll { $0.id == app.id }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
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
                    .foregroundColor(.gray)
                
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
                .fill(Color.white.opacity(0.05))
        )
        .padding()
    }
}

#Preview {
    ContentView()
}
