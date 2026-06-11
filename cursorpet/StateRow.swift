import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct StateRow: View {
  
  let state: BuddyState
  @ObservedObject var stateManager: StateManager
  
  @State private var isDropTargeted = false
  // first frame of the current gif / image for preview
  @State private var previewImage: NSImage? = nil
  
  var hasCustom: Bool {
    stateManager.hasCustomFile(for: state)
  }
  
  // path to whichever file is active (custom or bundle)
  private var activeFilePath: String? {
    if let custom = UserDefaults.standard.string(forKey: state.userDefaultsForCustomFileKey),
       FileManager.default.fileExists(atPath: custom) {
      return custom
    }
    // fall back to bundle gif
    return Bundle.main.url(forResource: state.defaultGifName, withExtension: "gif")?.path
  }
  
  var body: some View {
    HStack(spacing: 12) {
      
      // Preview thumbnail
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(isDropTargeted
                ? Color.accentColor.opacity(0.35)
                : Color.accentColor.opacity(0.12))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(isDropTargeted ? Color.accentColor : Color.clear, lineWidth: 2)
          )
        
        if let img = previewImage {
          Image(nsImage: img)
            .resizable()
            .scaledToFill()
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
          Text(stateEmoji)
            .font(.title2)
        }
        
        // small drag hint icon in corner
        if isDropTargeted {
          Image(systemName: "arrow.down.circle.fill")
            .foregroundColor(.accentColor)
            .font(.system(size: 20, weight: .semibold))
        }
      }
      .frame(width: 48, height: 48)
      // Drag & Drop
      .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
        handleDrop(providers: providers)
      }
      
      // Name / description / filename
      VStack(alignment: .leading, spacing: 2) {
        Text(state.displayName)
          .font(.body.weight(.medium))
        
        Text(state.description)
          .font(.caption)
          .foregroundColor(.secondary)
        
        if hasCustom,
           let path = UserDefaults.standard.string(forKey: state.userDefaultsForCustomFileKey) {
          Text(URL(fileURLWithPath: path).lastPathComponent)
            .font(.caption)
            .foregroundColor(.accentColor)
        }
      }
      
      Spacer()
      
      // Buttons
      HStack(spacing: 8) {
        if hasCustom {
          Button {
            stateManager.resetToDefault(for: state)
            loadPreview()
          } label: {
            Image(systemName: "arrow.counterclockwise")
          }
          .buttonStyle(.borderless)
          .foregroundColor(.secondary)
          .help("Back to default")
        }
        
        Button("Change...") {
          pickFile()
        }
        .buttonStyle(.bordered)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .onAppear { loadPreview() }
    // refresh preview when stateManager publishes a change
    .onChange(of: stateManager.currentState) { _ in loadPreview() }
  }
  
  // Emoji fallback
  private var stateEmoji: String {
    switch state {
    case .idle:      return "💤"
    case .hello:     return "👋"
    case .scrolling: return "📜"
    }
  }
  
  // Load first GIF frame off main thread
  private func loadPreview() {
    guard let path = activeFilePath else { previewImage = nil; return }
    let url = URL(fileURLWithPath: path)
    
    DispatchQueue.global(qos: .userInitiated).async {
      let img = firstFrame(of: url)
      DispatchQueue.main.async { previewImage = img }
    }
  }
  
  private func firstFrame(of url: URL) -> NSImage? {
    let ext = url.pathExtension.lowercased()
    // for lottie / json just show generic icon – no easy first-frame without rendering
    guard ext == "gif" || ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "webp" else {
      return NSImage(systemSymbolName: "sparkles", accessibilityDescription: nil)
    }
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
    return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
  }
  
  // Open panel (async – no main-thread block)
  private func pickFile() {
    let panel = NSOpenPanel()
    panel.title          = "Choose animation for «\(state.displayName)»"
    panel.message        = "Supported: GIF, Lottie (.lottie, .json)"
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories    = false
    
    if #available(macOS 12.0, *) {
      panel.allowedContentTypes = [
        .gif,
        UTType(filenameExtension: "lottie")!,
        .json
      ]
    }
    
    // begin(completionHandler:) is non-blocking – UI stays responsive
    panel.begin { response in
      guard response == .OK, let url = panel.url else { return }
      stateManager.setCustomFile(url: url, for: state)
      loadPreview()
    }
  }
  
  // Drag & drop handler
  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard let provider = providers.first else { return false }
    
    provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
      guard let data = item as? Data,
            let url  = URL(dataRepresentation: data, relativeTo: nil) else { return }
      
      let ext = url.pathExtension.lowercased()
      let allowed = ["gif", "lottie", "json"]
      guard allowed.contains(ext) else { return }
      
      DispatchQueue.main.async {
        stateManager.setCustomFile(url: url, for: state)
        loadPreview()
      }
    }
    return true
  }
}
