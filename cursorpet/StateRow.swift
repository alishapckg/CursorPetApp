import SwiftUI
import AppKit
import UniformTypeIdentifiers
struct StateRow: View {
  
  let state: BuddyState
  @ObservedObject var stateManager: StateManager
  
  var hasCustom: Bool {
    stateManager.hasCustomFile(for: state)
  }
  
  var body: some View {
    HStack(spacing: 12) {
      
      // preview - small animated icon
      // colored circle
      // in real app we can show first GIF frame
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.accentColor.opacity(0.15))
        .frame(width: 48, height: 48)
        .overlay(
          Text(stateEmoji)
            .font(.title2)
        )
      
      // name and description
      VStack(alignment: .leading, spacing: 2) {
        Text(state.displayName)
          .font(.body.medium())
        
        Text(state.description)
          .font(.caption)
          .foregroundColor(.secondary)
        
        // showing custom file name if it exists
        if hasCustom,
           let path = UserDefaults.standard.string(forKey: state.userDefaultsForCustomFileKey) {
          Text(URL(fileURLWithPath: path).lastPathComponent)
            .font(.caption)
            .foregroundColor(.accentColor)
        }
      }
      
      Spacer()
      
      HStack(spacing: 8) {
        
        // backing to default only if has custom file
        if hasCustom {
          Button {
            stateManager.resetToDefault(for: state)
          } label: {
            Image(systemName: "arrow.counterclockwise")
          }
          .buttonStyle(.borderless)
          .foregroundColor(.secondary)
          .help("Back to default")
        }
        
        // Choose file
        Button("Change...") {
          pickFile()
        }
        .buttonStyle(.bordered)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
  
  // emoji for state preview
  private var stateEmoji: String {
    switch state {
    case .idle:      return "💤"
    case .hello:     return "👋"
    case .scrolling: return "📜"
    }
  }
  
  private func pickFile() {
    let panel = NSOpenPanel()
    panel.title = "Choose animation for «\(state.displayName)»"
    panel.message = "Supported: GIF, Lottie (.lottie, .json)"
    
    // allowed file types
    if #available(macOS 12.0, *) {
      panel.allowedContentTypes = [
        .gif,                                        // GIF
        .init(filenameExtension: "lottie")!,         // .lottie файл
        .json                                        // Lottie JSON
      ]
    }
    
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    
    guard panel.runModal() == .OK, let url = panel.url else { return }
    
    stateManager.setCustomFile(url: url, for: state)
  }
}

private extension Font {
  func medium() -> Font { self.weight(.medium) }
}
