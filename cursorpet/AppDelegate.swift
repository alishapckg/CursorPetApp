import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
  
  private var overlayController = OverlayController()
  private var stateManager = StateManager()
  private var eventMonitor = EventMonitor()
  private var statusBar: StatusBarController?
  private var screenshotKeyMonitor = ScreenshotKeyMonitor()
  
  // same as viewDidLoad for UIViewController
  // system calls this methods when app is loaded
  func applicationDidFinishLaunching(_ notification: Notification) {
    setupConnections()
    overlayController.start()
    eventMonitor.start()
    screenshotKeyMonitor.start()
    
    stateManager.setStateTemporarily(.hello, for: 4.0, thenReturn: .idle)
    
    statusBar = StatusBarController(stateManager: stateManager, overlayController: overlayController)
  }
  
  private func setupConnections() {
    stateManager.onStateChange = { [weak self] _, content in
      self?.overlayController.show(content: content)
    }
    
    eventMonitor.onScrollStart = { [weak self] in
      self?.stateManager.setState(.scrolling)
    }
    
    eventMonitor.onScrollEnd = { [weak self] in
      self?.stateManager.setState(.idle)
    }
    
    eventMonitor.onIdle = { [weak self] in
      self?.stateManager.setState(.idle)
    }
    
    screenshotKeyMonitor.onScreenshot = { [weak self] in
      self?.handleScreenshot()
      
    }
  }
  
  private func handleScreenshot() {
    // Защита от дублирования — если уже в состоянии скриншота, игнорируем
    guard stateManager.currentState != .screenshot else { return }
    print("📸 Показываю эмоджи!")
    stateManager.setStateTemporarily(.screenshot, for: 2.0, thenReturn: .idle)
  }

  func applicationWillTerminate(_ notification: Notification) {
    eventMonitor.stop()
    screenshotKeyMonitor.stop()
    overlayController.stop()
  }
}
