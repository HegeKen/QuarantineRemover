import Foundation
import SwiftUI

class AppModel: ObservableObject {
    @Published var installedApps: [AppInfo] = []
    @Published var selectedApps: Set<String> = []
    @Published var droppedApps: [AppInfo] = []
    @Published var isProcessing = false
    @Published var statusMessage = ""
    @Published var showSuccess = false
    
    struct AppInfo: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let path: String
        let icon: NSImage?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(path)
        }
        
        static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
            lhs.path == rhs.path
        }
    }
    
    init() {
        loadInstalledApps()
    }
    
    func loadInstalledApps() {
        let applicationPaths = [
            "/Applications",
            "/Applications/Utilities",
            "\(NSHomeDirectory())/Applications"
        ]
        
        var apps: [AppInfo] = []
        
        for path in applicationPaths {
            guard let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: path),
                                                                 includingPropertiesForKeys: [.isApplicationKey],
                                                                 options: [.skipsHiddenFiles]) else {
                continue
            }
            
            while let fileURL = enumerator.nextObject() as? URL {
                if fileURL.pathExtension == "app" {
                    let appName = fileURL.deletingPathExtension().lastPathComponent
                    let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
                    icon.size = NSSize(width: 48, height: 48)
                    
                    let appInfo = AppInfo(name: appName, path: fileURL.path, icon: icon)
                    apps.append(appInfo)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.installedApps = apps.sorted { $0.name < $1.name }
        }
    }
    
    func toggleSelection(appPath: String) {
        if selectedApps.contains(appPath) {
            selectedApps.remove(appPath)
        } else {
            selectedApps.insert(appPath)
        }
    }
    
    func addDroppedApp(url: URL) {
        let appName = url.deletingPathExtension().lastPathComponent
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        icon.size = NSSize(width: 48, height: 48)
        
        let appInfo = AppInfo(name: appName, path: url.path, icon: icon)
        
        if !droppedApps.contains(where: { $0.path == appInfo.path }) {
            droppedApps.append(appInfo)
            selectedApps.insert(appInfo.path)
        }
    }
    
    func removeQuarantine(completion: @escaping (Bool, String) -> Void) {
        let appsToRemove = selectedApps.compactMap { path in
            droppedApps.first(where: { $0.path == path }) ??
            installedApps.first(where: { $0.path == path })
        }
        
        guard !appsToRemove.isEmpty else {
            completion(false, "请先选择要处理的应用")
            return
        }
        
        isProcessing = true
        statusMessage = "正在处理..."
        
        Task {
            var successCount = 0
            var failCount = 0
            var messages: [String] = []
            
            for app in appsToRemove {
                let result = await removeQuarantineFromApp(app: app)
                if result.success {
                    successCount += 1
                    messages.append("✓ \(app.name): 成功")
                } else {
                    failCount += 1
                    messages.append("✗ \(app.name): \(result.message)")
                }
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.statusMessage = "处理完成: \(successCount) 成功, \(failCount) 失败"
                self.showSuccess = successCount > 0
                
                let fullMessage = messages.joined(separator: "\n")
                completion(successCount > 0, fullMessage)
            }
        }
    }
    
    private func removeQuarantineFromApp(app: AppInfo) async -> (success: Bool, message: String) {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        process.arguments = ["-d", "com.apple.quarantine", app.path]
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                return (true, "成功移除隔离属性")
            } else {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? "未知错误"
                return (false, output.trimmingCharacters(in: .newlines))
            }
        } catch {
            return (false, error.localizedDescription)
        }
    }
    
    func clearDroppedApps() {
        droppedApps.removeAll()
        selectedApps.removeAll()
    }
}
