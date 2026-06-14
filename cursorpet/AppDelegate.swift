import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
  
  // Services & Managers
  private let stateManager = StateManager()
  private let settings = SettingsService.shared
  private let eventMonitor = EventMonitor()
  private let screenshotKeyMonitor = ScreenshotKeyMonitor()
  private let accessibilityManager = AccessibilityManager()
  private let xcodeMonitor = XcodeMonitor()
  
  // Logic
  private var orchestrator: BuddyOrchestrator!
  
  // UI Components
  private var overlayController: OverlayController!
  private var statusBar: StatusBarController?
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    UserDefaults.standard.register(defaults: ["overlaySize": 128.0, "offsetX": 16.0, "offsetY": 8.0])
    
    // 1. Init UI
    overlayController = OverlayController(settings: settings)
    overlayController.start()
    
    // 2. Bind UI to State
    stateManager.onStateChange = { [weak self] state, content in
      self?.overlayController.show(content: content)
    }
    
    // 3. Init Logic Layer (Orchestrator)
    orchestrator = BuddyOrchestrator(
      stateManager: stateManager,
      settings: settings,
      eventMonitor: eventMonitor,
      screenshotMonitor: screenshotKeyMonitor,
      xcodeMonitor: xcodeMonitor,
      accessibilityManager: accessibilityManager
    )
    orchestrator.start()
    
    // 4. Init Status Bar
    statusBar = StatusBarController(
      stateManager: stateManager,
      overlayController: overlayController,
      accessibilityManager: accessibilityManager
    )
  }
  
  func applicationWillTerminate(_ notification: Notification) {
    orchestrator.stop()
    overlayController.stop()
  }
}
