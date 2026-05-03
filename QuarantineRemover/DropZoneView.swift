import SwiftUI

struct DropZoneView: View {
    @Binding var isHovering: Bool
    let onDrop: ([URL]) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(isHovering ? 0.2 : 0.1),
                            Color.purple.opacity(isHovering ? 0.2 : 0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(isHovering ? 0.6 : 0.3),
                                    Color.purple.opacity(isHovering ? 0.6 : 0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
            
            VStack(spacing: 16) {
                Image(systemName: "app.badge")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                    .scaleEffect(isHovering ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isHovering)
                
                Text("拖放应用到此处")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("支持 .app 格式的应用程序")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 200)
        .onDrop(of: [.fileURL], isTargeted: $isHovering) { providers in
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let fileURL = url {
                        DispatchQueue.main.async {
                            self.onDrop([fileURL])
                        }
                    }
                }
            }
            return true
        }
    }
}
