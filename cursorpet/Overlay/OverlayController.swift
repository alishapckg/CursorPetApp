import AppKit

// main logic here
final class OverlayController {
  private var window: OverlayWindow?
  private var dotView: DotView?
  private var trackingTimer: Timer?
  private var isEnabled = true
  
  private var scrollMonitor: Any?
  private var scrollTimer: Timer?
  
  
  // dot settings
  // to change in app delegate
  var dotColor: NSColor = .systemRed
  var dotSize: CGFloat = 12
  var dotOffset: CGPoint = CGPoint(x: 16, y: -16) // offset by cursor
  
  func start() {
    setupWindow()
    startTracking()
  }
  
  private func setupWindow() {
    window = OverlayWindow()
    dotView = DotView(frame: NSRect(x: 0, y: 0, width: dotSize, height: dotSize))
    dotView?.color = dotColor
    dotView?.size = dotSize
    
    // contentView is root view of window
    // add subview - adding our dot as child view
    // NSWindow -> contentView (NSView) -> dotView(DotView)
    window?.contentView?.addSubview(dotView!) // need to remove force unwrap
    
    // makeKeyAndOrderFront - showing window
    // nil - without animation
    // key window - window that gets events of keyboard, but for us its not important (ignoresMouseEvents = true)
    // but this method we need to show window on our screen
    window?.makeKeyAndOrderFront(nil)
  }
  // timer 60 fps for updating position
  private func startTracking() {
    trackingTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
      self?.updateDotPosition()
    }
    
    // cycle of handling events
    // macos loops this cycle and checks - is there new event of mouse, timer, system messages
    // common - mode where timer works all the time even when the user scrolls or drags windows
    RunLoop.main.add(trackingTimer!, forMode: .common) // need to remove force unwrap
    
    scrollMonitor = NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) { [weak self] _ in
      self?.handleScroll()
      
    }
  }
  
  private func handleScroll() {
    dotView?.shape = .square
    
    scrollTimer?.invalidate()
    scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
      self?.dotView?.shape = .circle
    }
  }
  
  private func updateDotPosition() {
    guard isEnabled else { return }
    // cursor location in screen coordinates
    let mouseLocation = NSEvent.mouseLocation
    
    // converting to window coordinates (in macos y is reversed)
    guard let screen = NSScreen.main else { return }
    let screenHeight = screen.frame.height
    
    let x = mouseLocation.x + dotOffset.x
    // appkit calculates y from bottom, so making reversed
    let y = screenHeight - mouseLocation.y + dotOffset.y
    
    dotView?.frame = NSRect(x: x, y: screenHeight - y - dotSize, width: dotSize, height: dotSize)
  }
  
  func toggle() {
    isEnabled.toggle()
    dotView?.isHidden = !isEnabled
  }
  
  func stop() {
    trackingTimer?.invalidate()
    trackingTimer = nil
    scrollTimer?.invalidate()
    
    if let scrollMonitor {
      NSEvent.removeMonitor(scrollMonitor)
    }
    
    // orderOut removes window from screen (but not from storage)
    // nil - without animation
    window?.orderOut(nil)
  }
  
  func applySettings() {
    let size = UserDefaults.standard.double(forKey: "dotSize")
    dotSize = size > 0 ? CGFloat(size) : 12
    let r = UserDefaults.standard.double(forKey: "dotColorRed")
    let g = UserDefaults.standard.double(forKey: "dotColorGreen")
    let b = UserDefaults.standard.double(forKey: "dotColorBlue")
    
    if r+g+b > 0 {
      dotColor = NSColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    dotView?.color = dotColor
    dotView?.size = dotSize
  }
  
}
