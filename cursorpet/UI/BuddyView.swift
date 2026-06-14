import AppKit

final class BuddyView: NSView {
  private var gifView: GIFPlayerView?
  private var emojiLabel: NSTextField?
  
  func show(_ content: BuddyContent) {
    switch content {
    case .bundleGIF(let name):
      showGIF(named: name)
    case .gif(let url):
      showGIF(url: url)
      
    case .emoji(let emoji):
      showEmoji(emoji)
    }
  }
  
  private func showGIF(named name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "gif") else {
      print("buddy view not found with name \(name)")
      return
    }
    removeEmoji()
    showGIF(url: url)
  }
  
  private func showGIF(url: URL) {
    removeEmoji()
    
    if gifView == nil {
      let gv = GIFPlayerView(frame: bounds)
      gv.autoresizingMask = [.width, .height]
      addSubview(gv)
      self.gifView = gv
    }
    
    self.gifView?.load(url: url)
  }
  
  private func showEmoji(_ emoji: String) {
    removeGIF()
    removeEmoji()
    
    let label = NSTextField(labelWithString: emoji)
    label.font = NSFont.systemFont(ofSize: 100)
    label.alignment = .center
    label.frame = bounds
    label.autoresizingMask = [.width, .height]
    label.backgroundColor = .clear
    label.isBezeled = false
    label.isEditable = false
    
    addSubview(label)
    emojiLabel = label
  }
  
  
  private func removeEmoji() {
    emojiLabel?.removeFromSuperview()
    emojiLabel = nil
  }
  
  private func removeGIF() {
    gifView?.stop()
    gifView?.removeFromSuperview()
    gifView = nil
  }
  
  func stopAll() {
    removeGIF()
    removeEmoji()
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
