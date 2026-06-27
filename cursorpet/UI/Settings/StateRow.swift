import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct StateRow: View {
  let state: BuddyState
  @ObservedObject var stateManager: StateManager
  @ObservedObject var accessibilityManager: AccessibilityManager
  let onBrowseGiphy: (BuddyState) -> Void
  
  @State private var isDropTargeted = false
  @State private var previewImage: NSImage? = nil
  @State private var isHovered = false
  
  private let fileStorage = FileStorageService.shared
  
  private let cardBg      = Color.white.opacity(0.05)
  private let cardActive  = Color(hex: "#00FF88").opacity(0.12)
  private let cardBorder  = Color.white.opacity(0.08)
  private let accentBorder = Color(hex: "#00FF88").opacity(0.28)
  private let accent      = Color(hex: "#00FF88")
  private let previewBg   = Color(hex: "#1E1A28")
  private let textPri     = Color(hex: "#F5F3FF")
  private let textSec     = Color.white.opacity(0.55)
  private let textDim     = Color.white.opacity(0.20)
  
  private var isActive: Bool { stateManager.currentState == state }
  var hasCustom: Bool { fileStorage.getCustomFileURL(for: state) != nil }
  
  private var isScreenshotDisabled: Bool {
    state == .screenshot && !accessibilityManager.isEnabled
  }
  
  private var activeFilePath: String? {
    if let custom = fileStorage.getCustomFileURL(for: state) { return custom.path }
    return Bundle.main.url(forResource: state.defaultGifName, withExtension: "gif")?.path
  }
  
  var body: some View {
    HStack(spacing: 12) {
      
      // Preview
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(isDropTargeted ? accent.opacity(0.20) : previewBg)

        if let img = previewImage {
          Image(nsImage: img)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .opacity(isDropTargeted ? 0.4 : 1)
            .blur(radius: isScreenshotDisabled ? 6 : 0)
        } else {
          Text(stateEmoji)
            .font(.system(size: 26))
            .opacity(isDropTargeted ? 0.3 : 1)
        }

        if isDropTargeted {
          Image(systemName: "arrow.down.circle.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(accent)
        }
      }
      .frame(width: 52, height: 52)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .strokeBorder(
            isDropTargeted ? accent : cardBorder,
            style: StrokeStyle(lineWidth: isDropTargeted ? 1.5 : 0.5,
                               dash: isDropTargeted ? [4, 3] : [])
          )
      )
      .overlay(
        isScreenshotDisabled ?
        Image(systemName: "lock.fill")
          .font(.system(size: 16, weight: .semibold))
          .foregroundColor(Color.white.opacity(0.6))
        : nil
      )
      .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
        guard !isScreenshotDisabled else { return false }
        return handleDrop(providers: providers)
      }
      
      // Text
      VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 4) {
          Text(state.displayName)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isScreenshotDisabled ? textPri.opacity(0.4) : textPri)
          
          if isScreenshotDisabled {
            Image(systemName: "lock.fill")
              .font(.system(size: 10))
              .foregroundColor(Color(hex: "#FFB800"))
          }
        }
        
        Text(state.description)
          .font(.system(size: 12))
          .foregroundColor(isScreenshotDisabled ? textSec.opacity(0.4) : textSec)
        
        if let url = fileStorage.getCustomFileURL(for: state) {
          Text(url.lastPathComponent)
            .font(.system(size: 11))
            .foregroundColor(accent)
        } else {
          Text("\(state.defaultGifName).gif  ·  default")
            .font(.system(size: 11))
            .foregroundColor(isScreenshotDisabled ? textDim.opacity(0.5) : textDim)
        }
      }
      
      Spacer()
      
      // Buttons
      HStack(spacing: 6) {
        if hasCustom && !isScreenshotDisabled {
          DarkIconButton(systemName: "arrow.counterclockwise", help: "Back to default") {
            fileStorage.resetCustomFile(for: state)
            if stateManager.currentState == state {
              stateManager.setState(state)
            }
            loadPreview()
          }
        }
        if !isScreenshotDisabled {
          DarkTextButton("GIPHY") { onBrowseGiphy(state) }
          DarkTextButton("Change…") { pickFile() }
        }
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(isActive ? cardActive : (isHovered ? Color.white.opacity(0.07) : cardBg))
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .strokeBorder(isActive ? accentBorder : cardBorder, lineWidth: 0.5)
        )
    )
    .onHover { isHovered = $0 }
    .animation(.easeOut(duration: 0.12), value: isHovered)
    .onAppear { loadPreview() }
    .onChange(of: stateManager.currentState) { _ in loadPreview() }
  }
  
  private var stateEmoji: String {
    switch self.state {
    case .idle:      return "💤"
    case .hello:     return "👋"
    case .scrolling: return "📜"
    case .screenshot: return "📸"
    case .xcodeHappy: return "😊"
    case .xcodeAngry: return "😩"
//    case .typing: return "⌨️"
//    case .longIdle: return "😇"
//    case .lowBattery: return "🪫"
    }
  }
  
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
    guard ["gif","png","jpg","jpeg","webp"].contains(ext) else {
      return NSImage(systemSymbolName: "sparkles", accessibilityDescription: nil)
    }
    guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    let count = CGImageSourceGetCount(src)
    let index = Int.random(in: 0..<count)
    guard let cg = CGImageSourceCreateImageAtIndex(src, index, nil) else { return nil }
    return NSImage(cgImage: cg, size: NSSize(width: cg.width, height: cg.height))
  }
  
  private func pickFile() {
    guard !isScreenshotDisabled else { return }
    
    let panel = NSOpenPanel()
    panel.title = "Choose animation for «\(state.displayName)»"
    panel.message = "Supported: GIF, Lottie (.lottie, .json)"
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    if #available(macOS 12.0, *) {
      panel.allowedContentTypes = [.gif, UTType(filenameExtension: "lottie")!, .json]
    }
    panel.begin { response in
      guard response == .OK, let url = panel.url else { return }
      self.fileStorage.setCustomFile(url: url, for: state)
      
      if self.stateManager.currentState == self.state {
        self.stateManager.setState(self.state)
      }
      self.loadPreview()
    }
  }
  
  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard !isScreenshotDisabled else { return false }
    
    guard let provider = providers.first else { return false }
    provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
      guard let data = item as? Data,
            let url  = URL(dataRepresentation: data, relativeTo: nil),
            ["gif","lottie","json"].contains(url.pathExtension.lowercased()) else { return }
      DispatchQueue.main.async {
        self.fileStorage.setCustomFile(url: url, for: state)
        if self.stateManager.currentState == self.state {
          self.stateManager.setState(self.state)
        }
        self.loadPreview()
      }
    }
    return true
  }
}

// MARK: - UI Components (Helpers)

private struct DarkIconButton: View {
  let systemName: String
  let help: String
  let action: () -> Void
  @State private var hovered = false
  
  var body: some View {
    Button(action: action) {
      Image(systemName: systemName)
        .font(.system(size: 12))
        .foregroundColor(hovered ? Color.white.opacity(0.85) : Color.white.opacity(0.45))
        .frame(width: 28, height: 26)
        .background(
          RoundedRectangle(cornerRadius: 6)
            .fill(Color.white.opacity(hovered ? 0.10 : 0.06))
            .overlay(RoundedRectangle(cornerRadius: 6)
              .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.5))
        )
    }
    .buttonStyle(.plain)
    .onHover { hovered = $0 }
    .help(help)
  }
}

private struct DarkTextButton: View {
  let title: String
  let action: () -> Void
  @State private var hovered = false
  
  init(_ title: String, action: @escaping () -> Void) {
    self.title = title
    self.action = action
  }
  
  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 12))
        .foregroundColor(hovered ? Color(hex: "#F5F3FF") : Color.white.opacity(0.75))
        .padding(.horizontal, 10)
        .frame(height: 26)
        .background(
          RoundedRectangle(cornerRadius: 6)
            .fill(Color.white.opacity(hovered ? 0.10 : 0.06))
            .overlay(RoundedRectangle(cornerRadius: 6)
              .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.5))
        )
    }
    .buttonStyle(.plain)
    .onHover { hovered = $0 }
  }
}
