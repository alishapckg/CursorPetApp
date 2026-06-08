import AppKit

// main logic here
final class OverlayController {
  private var window: OverlayWindow?
  private var buddyView: BuddyView?
  private var positionTimer: Timer?
  private var isVisible = true
  
  
  
  // dot settings
  // to change in app delegate
//  var dotColor: NSColor = .systemRed
//  var dotSize: CGFloat = 12
//  var dotOffset: CGPoint = CGPoint(x: 16, y: -16) // offset by cursor
  
  var size: CGFloat {
    CGFloat(UserDefaults.standard.double(forKey: "overlaySize").nonZero ?? 64) // nonZero?
  }
  
  var offset: CGPoint {
    let x = UserDefaults.standard.double(forKey: "offsetX").nonZero ?? 16 // nonZero
    let y = UserDefaults.standard.double(forKey: "offsetY").nonZero ?? 8 // nonZero
    return CGPoint(x: x, y: y)
  }
  
  func start() {
    setupWindow()
    startTracking()
  }
  
  private func setupWindow() {
    window = OverlayWindow()
    buddyView = BuddyView(frame: NSRect(x: 0, y: 0, width: size, height: size))
    
    // contentView is root view of window
    // add subview - adding our dot as child view
    // NSWindow -> contentView (NSView) -> dotView(DotView)
    window?.contentView?.addSubview(buddyView!) // need to remove force unwrap
    
    // makeKeyAndOrderFront - showing window
    // nil - without animation
    // key window - window that gets events of keyboard, but for us its not important (ignoresMouseEvents = true)
    // but this method we need to show window on our screen
    window?.makeKeyAndOrderFront(nil)
  }
  // timer 60 fps for updating position
  private func startTracking() {
    positionTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
      self?.updatePosition()
    }
    
    // cycle of handling events
    // macos loops this cycle and checks - is there new event of mouse, timer, system messages
    // common - mode where timer works all the time even when the user scrolls or drags windows
    RunLoop.main.add(positionTimer!, forMode: .common) // need to remove force unwrap
  }
  
  private func updatePosition() {
    guard isVisible else { return }
    // cursor location in screen coordinates
    let mouseLocation = NSEvent.mouseLocation
    let s = size
    
    buddyView?.frame = NSRect(x: mouseLocation.x + offset.x, y: mouseLocation.y + offset.y, width: s, height: s)
  }
  
  func show(content: BuddyContent) {
    buddyView?.show(content)
  }
  
  func setVisible(_ visible: Bool) {
    self.isVisible = visible
    buddyView?.isHidden = !visible
  }
  
  func toggle() {
    setVisible(!isVisible)
  }
  
  func stop() {
    positionTimer?.invalidate()
    buddyView?.stopAll()
    window?.orderOut(nil)
  }
  
}

private extension Double {
  var nonZero: Double? { self == 0 ? nil : self }
}
