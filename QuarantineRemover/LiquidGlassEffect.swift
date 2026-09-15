import SwiftUI

struct LiquidGlassBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    /// 基础背景渐变色
    private var backgroundColors: [Color] {
        if isDark {
            return [
                Color(red: 0.10, green: 0.10, blue: 0.20),
                Color(red: 0.15, green: 0.15, blue: 0.25),
                Color(red: 0.20, green: 0.20, blue: 0.30)
            ]
        } else {
            return [
                Color(red: 0.92, green: 0.94, blue: 1.00),
                Color(red: 0.88, green: 0.90, blue: 0.98),
                Color(red: 0.82, green: 0.85, blue: 0.95)
            ]
        }
    }

    /// 流动光斑颜色（深色用白光、浅色用淡蓝光以增加层次）
    private var orbColor: Color {
        isDark ? .white : Color(red: 0.55, green: 0.70, blue: 1.00)
    }

    var body: some View {
        ZStack {
            // 基础渐变背景
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 流动的光效
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                orbColor.opacity(0.10),
                                orbColor.opacity(0.05),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(
                        x: CGFloat(index) * 200 - 200,
                        y: CGFloat(index) * 150 - 100
                    )
                    .blur(radius: 50)
                    .animation(
                        Animation.easeInOut(duration: 4 + Double(index))
                            .repeatForever(autoreverses: true),
                        value: index
                    )
            }
        }
    }
}

struct LiquidGlassCard: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        // 卡片填充色：深色模式用白色低不透明度，浅色模式用黑色低不透明度
        let baseTint: Color = isDark ? .white : .black
        return content
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                baseTint.opacity(0.10),
                                baseTint.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        baseTint.opacity(0.30),
                                        baseTint.opacity(0.10)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(isDark ? 0.20 : 0.08), radius: 10, x: 0, y: 5)
            )
    }
}

struct LiquidGlassButton: ViewModifier {
    let isPrimary: Bool
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        // 次要按钮的玻璃质感：随明暗模式切换底色来源
        let secondaryTint: Color = isDark ? .white : .black
        // 主按钮为蓝底，文字恒用白色；次要按钮文字需随明暗自适应
        let labelColor: Color = isPrimary ? .white : .primary
        let strokeTint: Color = isDark ? .white : .black
        return content
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(labelColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isPrimary {
                        // 主按钮：蓝色在明暗模式下都可读
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.85),
                                Color.blue.opacity(0.65)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                secondaryTint.opacity(0.15),
                                secondaryTint.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                strokeTint.opacity(isPrimary ? 0.40 : 0.25),
                                strokeTint.opacity(0.10)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(isDark ? 0.30 : 0.12), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func liquidGlassCard() -> some View {
        self.modifier(LiquidGlassCard())
    }

    func liquidGlassButton(isPrimary: Bool = true) -> some View {
        self.modifier(LiquidGlassButton(isPrimary: isPrimary))
    }
}
