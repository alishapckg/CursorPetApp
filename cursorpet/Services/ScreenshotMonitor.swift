import CoreGraphics
import ApplicationServices

final class ScreenshotKeyMonitor {
  var onScreenshot: (() -> Void)?
  
  private var eventTap: CFMachPort?
  private var runLoopSource: CFRunLoopSource?
  
  static var isAccessibilityEnabled: Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false]
    return AXIsProcessTrustedWithOptions(options as CFDictionary)
  }
  
  func start() {
    guard Self.isAccessibilityEnabled else {
      print("Accessibility not granted. Screenshot shortcut monitoring desabled.")
      return
    }
    
    let callback: CGEventTapCallBack = { proxy, type, event, refcon -> Unmanaged<CGEvent>? in
      guard let refcon = refcon else { return Unmanaged.passRetained(event) }
      let monitor = Unmanaged<ScreenshotKeyMonitor>.fromOpaque(refcon).takeUnretainedValue()
      
      guard type == .keyDown else { return Unmanaged.passRetained(event) }
      
      let flags = event.flags
      let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
      
      // Cmd+Shift+3 (20), Cmd+Shift+4 (21), Cmd+Shift+5 (23)
      let isScreenshotKey = (keyCode == 20 || keyCode == 21 || keyCode == 23)
      let isCmdShift = flags.contains(.maskCommand) && flags.contains(.maskShift)
      
      if isCmdShift && isScreenshotKey {
        print("📸 Screenshot shortcut detected instantly!")
        DispatchQueue.main.async {
          monitor.onScreenshot?()
        }
      }
      
      return Unmanaged.passRetained(event)
    }
    
    guard let tap = CGEvent.tapCreate(
      tap: .cgSessionEventTap,
      place: .headInsertEventTap,
      options: .defaultTap,
      eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
      callback: callback,
      userInfo: Unmanaged.passUnretained(self).toOpaque()
    ) else {
      print("❌ CGEventTap failed. Enable Accessibility in System Settings.")
      return
    }
    
    eventTap = tap
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
    
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let source = self?.runLoopSource else { return }
      CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
      CGEvent.tapEnable(tap: tap, enable: true)
      CFRunLoopRun()
    }
  }
  
  func stop() {
    if let tap = eventTap {
      CGEvent.tapEnable(tap: tap, enable: false)
    }
    eventTap = nil
    runLoopSource = nil
  }
}
