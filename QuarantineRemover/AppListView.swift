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
                    .foregroundColor(.gray)
                
                TextField("搜索应用...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(12)
            .liquidGlassCard()
            .padding(.horizontal)
            .padding(.top)
            
            // 应用列表
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredApps) { app in
                        AppRowView(app: app, isSelected: model.selectedApps.contains(app.path)) {
                            model.toggleSelection(appPath: app.path)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

struct AppRowView: View {
    let app: AppModel.AppInfo
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 应用图标
                Group {
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: "app")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                    }
                }
                
                // 应用名称
                Text(app.name)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                // 选择指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? Color.blue.opacity(0.5) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
