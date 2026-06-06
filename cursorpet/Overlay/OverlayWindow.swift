import AppKit

final class OverlayWindow: NSWindow {
  init() {
    
    // size is all main screen
    
    let screen = NSScreen.main?.frame ?? .zero
    super.init(contentRect: screen, styleMask: [.borderless], backing: .buffered, defer: false)
    backgroundColor = .clear
    isOpaque = false
    
    // over all
    level = .screenSaver
    
    // not mixing mouse events
    ignoresMouseEvents = true
    
    // not appearing in Mission Control / Spaces
    collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
    
    // doesnt glitch when switching apps
    animationBehavior = .none
  }
}
