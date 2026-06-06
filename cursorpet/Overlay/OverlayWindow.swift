import AppKit

final class OverlayWindow: NSWindow {
  init() {
    
    // size is all main screen
    let screen = NSScreen.main?.frame ?? .zero
    super.init(
      contentRect: screen, // size - the whole screen
      
      // appearance for window
      // borderless - without title, buttons, frame
      // titled - with title
      // resizable - can be stretched
      // miniaturizable - button "hide"
      // closable - button "close"
      styleMask: [.borderless],
      
      // how window saves pixels in storage
      // buffered - drawing to buffer, then displays (standard)
      // retained / non retained
      backing: .buffered,
      // defer false - create window now
      // defer true - delay before first display (saves storage)
      defer: false
    )
    backgroundColor = .clear
    isOpaque = false
    
    // z order
    // normal - usual window of app
    // floating - over usual windows
    // modalPanel - modal dialogues
    // screenSaver - over all apps
    level = .screenSaver
    
    // not mixing mouse events
    ignoresMouseEvents = true
    
    // behaviour in Spaces and MissionControl
    // canJoinAllSpaces - window is visible on all desktops (spaces)
    // stationary = doesnt move when switching spaces
    // ignores cycle - doesnt mix Tab and MissionControl
    collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
    
    // doesnt glitch when switching apps
    animationBehavior = .none
  }
}
