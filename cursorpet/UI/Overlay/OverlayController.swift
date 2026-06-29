import AppKit

final class OverlayController {
  private var window: OverlayWindow?
  private var buddyView: BuddyView?
  private var positionTimer: Timer?
  private var isVisible = true
  
  private let settings: SettingsServiceProtocol
  
  init(settings: SettingsServiceProtocol = SettingsService.shared) {
    self.settings = settings
  }
  
  var size: CGFloat { settings.overlaySize }
  var offset: CGPoint { settings.overlayOffset }
  
  func start() {
    setupWindow()
    startTracking()
  }
  
  private func setupWindow() {
    window = OverlayWindow()
    
    buddyView = BuddyView(frame: NSRect(x: 0, y: 0, width: size, height: size))
    
    window?.contentView?.addSubview(buddyView!)
    window?.makeKeyAndOrderFront(nil)
  }
  
  private func startTracking() {
    positionTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
      self?.updatePosition()
    }
    RunLoop.main.add(positionTimer!, forMode: .common)
  }
  
  private func updatePosition() {
    guard isVisible else { return }
    let mouseLocation = NSEvent.mouseLocation
    let s = size
    let o = offset
    
    buddyView?.frame = NSRect(x: mouseLocation.x + o.x, y: mouseLocation.y + o.y, width: s, height: s)
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
    positionTimer = nil
    buddyView?.stopAll()
    buddyView?.removeFromSuperview()
    buddyView = nil
    window?.orderOut(nil)
    window = nil
  }
}
