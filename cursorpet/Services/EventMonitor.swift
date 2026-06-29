import AppKit

final class EventMonitor {
  var onScrollStart: (() -> Void)?
  var onScrollEnd: (() -> Void)?
  var onIdle: (() -> Void)?
  var onActivity: (() -> Void)?
  
  private var scrollMonitor: Any?
  private var mouseMonitor: Any?
  private var idleTimer: Timer?
  private var scrollEndTimer: Timer?
  
  // watching how much not active - going to idle status
  var idleTimeout: TimeInterval = 0.5

  deinit { stop() }

  func start() {
    startScrollMonitor()
    startIdleTracking()
  }
  
  func stop() {
    if let scrollMonitor {
      
      NSEvent.removeMonitor(scrollMonitor)
    }
    
    if let mouseMonitor {
      NSEvent.removeMonitor(mouseMonitor)
    }
    idleTimer?.invalidate()
    scrollEndTimer?.invalidate()
  }
  
  private func startScrollMonitor() {
    scrollMonitor = NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
      let delta = abs(event.scrollingDeltaY) + abs(event.scrollingDeltaX)
      guard delta > 0.5 else { return }
      self?.handleScroll()
    }
  }
  
  private func handleScroll() {
    resetIdleTimer()
    onScrollStart?()
    
    scrollEndTimer?.invalidate()
    scrollEndTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
      self?.onScrollEnd?()
    }
  }
  
  private func startIdleTracking() {
    mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown]) { [weak self] _ in
      self?.resetIdleTimer()
    }
    
    resetIdleTimer()
  }
  
  private func resetIdleTimer() {
    let wasIdle = !(idleTimer?.isValid ?? false)
    idleTimer?.invalidate()
    idleTimer = Timer.scheduledTimer(withTimeInterval: idleTimeout, repeats: false) { [weak self] _ in
      self?.onIdle?()
      self?.idleTimer = nil
    }
    
    if wasIdle {
      onActivity?()
    }
  }
}
