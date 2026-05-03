# 隔离属性移除工具 (Quarantine Remover)

一个 macOS 应用，用于移除应用的隔离属性 (com.apple.quarantine)。

## 功能特性

- **Liquid Glass 设计风格**：现代化的半透明玻璃态界面
- **拖放支持**：直接将应用拖放到界面中
- **应用列表**：自动检测已安装的应用程序
- **批量处理**：可同时选择多个应用进行处理
- **实时反馈**：显示处理状态和结果

## 系统要求

- macOS 14.0 或更高版本
- Xcode 15.0 或更高版本（用于编译）

## 使用方法

### 方法一：从应用列表选择

1. 打开应用后，右侧会显示所有已安装的应用
2. 点击应用名称左侧的圆圈进行选择
3. 可以搜索应用名称快速定位
4. 点击底部的"移除隔离属性"按钮

### 方法二：拖放应用

1. 从 Finder 中找到要处理的应用
2. 将应用拖放到左侧的拖放区域
3. 点击底部的"移除隔离属性"按钮

## 技术说明

该应用在后台执行以下命令来移除隔离属性：

```bash
xattr -d com.apple.quarantine /path/to/application.app
```

## 编译和运行

### 使用 Xcode

1. 打开 `QuarantineRemover.xcodeproj`
2. 选择目标设备为 "My Mac"
3. 点击运行按钮 (⌘R)

### 使用命令行

```bash
cd QuarantineRemover
xcodebuild -project QuarantineRemover.xcodeproj -scheme QuarantineRemover build
```

编译后的应用位于：
```
~/Library/Developer/Xcode/DerivedData/QuarantineRemover-*/Build/Products/Debug/QuarantineRemover.app
```

## 注意事项

- 本应用需要禁用沙盒才能执行 xattr 命令
- 移除隔离属性后，应用可以直接打开而不会出现"无法验证开发者"的警告
- 请确保您信任要处理的应用

## 项目结构

```
QuarantineRemover/
├── QuarantineRemoverApp.swift    # 应用入口
├── ContentView.swift             # 主界面
├── AppModel.swift                # 数据模型和业务逻辑
├── DropZoneView.swift            # 拖放区域组件
├── AppListView.swift             # 应用列表组件
├── LiquidGlassEffect.swift       # Liquid Glass 视觉效果
└── Assets.xcassets/              # 资源文件
```

## 许可证

GNU GENERAL PUBLIC LICENSE
