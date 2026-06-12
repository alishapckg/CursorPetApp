import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
  
  private var overlayController = OverlayController()
  private var stateManager = StateManager()
  private var eventMonitor = EventMonitor()
  private var statusBar: StatusBarController?
  private var screenshotKeyMonitor = ScreenshotKeyMonitor()
  private var accessibilityManager = AccessibilityManager()
  private var xcodeMonitor = XcodeMonitor()
  private var cancellables = Set<AnyCancellable>()
  private var xcodeTimer: Timer? // ← таймер для сброса Xcode-состояний
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    setupConnections()
    overlayController.start()
    eventMonitor.start()
    accessibilityManager.startMonitoring()
    xcodeMonitor.start()
    
    if accessibilityManager.isEnabled {
      screenshotKeyMonitor.start()
    }
    
    stateManager.setStateTemporarily(.hello, for: 4.0, thenReturn: .idle)
    
    statusBar = StatusBarController(
      stateManager: stateManager,
      overlayController: overlayController,
      accessibilityManager: accessibilityManager
    )
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
    
    accessibilityManager.$isEnabled
      .dropFirst()
      .sink { [weak self] isEnabled in
        if isEnabled {
          self?.screenshotKeyMonitor.start()
        } else {
          self?.screenshotKeyMonitor.stop()
        }
      }
      .store(in: &cancellables)
    
    screenshotKeyMonitor.onScreenshot = { [weak self] in
      self?.handleScreenshot()
    }
    
    // ← НОВОЕ: реагируем только на изменения состояния Xcode
    xcodeMonitor.$state
      .sink { [weak self] state in
        self?.handleXcodeState(state)
      }
      .store(in: &cancellables)
  }
  
  private func handleXcodeState(_ state: XcodeMonitor.State) {
    // Не прерываем screenshot, hello, scrolling
    guard stateManager.currentState != .screenshot else { return }
    guard stateManager.currentState != .hello else { return }
    guard stateManager.currentState != .scrolling else { return }
    
    xcodeTimer?.invalidate()
    
    switch state {
    case .runningInactive:
      stateManager.setState(.xcodeAngry)
      xcodeTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
        if self?.stateManager.currentState == .xcodeAngry {
          self?.stateManager.setState(.idle)
        }
      }
      
    case .runningActive:
      stateManager.setState(.xcodeHappy)
      xcodeTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
        if self?.stateManager.currentState == .xcodeHappy {
          self?.stateManager.setState(.idle)
        }
      }
      
    case .notRunning:
      // Xcode закрыт — сразу в idle
      if stateManager.currentState != .idle {
        stateManager.setState(.idle)
      }
    }
  }
  
  private func handleScreenshot() {
    guard stateManager.currentState != .screenshot else { return }
    xcodeTimer?.invalidate() // ← сбрасываем Xcode-таймер, если скриншот
    stateManager.setStateTemporarily(.screenshot, for: 2.0, thenReturn: .idle)
  }

  func applicationWillTerminate(_ notification: Notification) {
    eventMonitor.stop()
    screenshotKeyMonitor.stop()
    accessibilityManager.stop()
    xcodeMonitor.stop()
    xcodeTimer?.invalidate()
    overlayController.stop()
  }
}
