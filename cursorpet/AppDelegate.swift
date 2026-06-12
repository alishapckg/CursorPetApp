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
  
  private var isXcodeDominant = false
  // Флаг, чтобы не запускать монитор Xcode несколько раз
  private var isMonitoringXcode = false
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    setupConnections()
    overlayController.start()
    eventMonitor.start()
    accessibilityManager.startMonitoring()
    
    // Запускаем мониторинг Xcode только если включен дев мод
    if UserDefaults.standard.bool(forKey: "devMode") {
      xcodeMonitor.start()
      isMonitoringXcode = true
    }
    
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
    stateManager.onStateChange = { [weak self] state, content in
      guard let self = self else { return }
      
      let isDevMode = UserDefaults.standard.bool(forKey: "devMode")
      
      if !isDevMode && (state == .xcodeAngry || state == .xcodeHappy) {
        self.stateManager.setState(.idle)
        return
      }
      
      self.overlayController.show(content: content)
    }
    
    eventMonitor.onScrollStart = { [weak self] in
      guard let self = self else { return }
      if self.isXcodeDominant { return }
      self.stateManager.setState(.scrolling)
    }
    
    eventMonitor.onScrollEnd = { [weak self] in
      guard let self = self else { return }
      if self.isXcodeDominant { return }
      self.stateManager.setState(.idle)
    }
    
    eventMonitor.onIdle = { [weak self] in
      guard let self = self else { return }
      if self.isXcodeDominant { return }
      self.stateManager.setState(.idle)
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
    
    xcodeMonitor.$state
      .sink { [weak self] state in
        self?.handleXcodeState(state)
      }
      .store(in: &cancellables)
    
    // Слушаем изменения настроек
    NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        let isDevMode = UserDefaults.standard.bool(forKey: "devMode")
        
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          if isDevMode {
            // Запускаем ТОЛЬКО если еще не запущен
            if !self.isMonitoringXcode {
              self.xcodeMonitor.start()
              self.isMonitoringXcode = true
            }
          } else {
            // Останавливаем ТОЛЬКО если запущен
            if self.isMonitoringXcode {
              self.xcodeMonitor.stop()
              self.isMonitoringXcode = false
            }
            // Сбрасываем состояние
            if self.stateManager.currentState == .xcodeAngry || self.stateManager.currentState == .xcodeHappy {
              self.stateManager.setState(.idle)
            }
          }
          
          // Проверяем состояние (нужно для мгновенной реакции при включении)
          self.handleXcodeState(self.xcodeMonitor.state)
        }
      }
      .store(in: &cancellables)
  }
  
  private func handleXcodeState(_ state: XcodeMonitor.State) {
    let isDevMode = UserDefaults.standard.bool(forKey: "devMode")
    
    if !isDevMode {
      isXcodeDominant = false
      return
    }
    
    switch state {
    case .notRunning:
      isXcodeDominant = false
      if stateManager.currentState == .xcodeAngry || stateManager.currentState == .xcodeHappy {
        stateManager.setState(.idle)
      }
      
    case .runningInactive:
      isXcodeDominant = true
      stateManager.setState(.xcodeAngry)
      
    case .runningActive:
      isXcodeDominant = false
      
      guard stateManager.currentState != .screenshot else { return }
      guard stateManager.currentState != .hello else { return }
      
      stateManager.setStateTemporarily(.xcodeHappy, for: 3.0, thenReturn: .idle)
    }
  }
  
  private func handleScreenshot() {
    guard stateManager.currentState != .screenshot else { return }
    
    let isDevMode = UserDefaults.standard.bool(forKey: "devMode")
    let returnState: BuddyState
    
    if isDevMode && xcodeMonitor.state == .runningInactive {
      returnState = .xcodeAngry
    } else {
      returnState = .idle
    }
    
    stateManager.setStateTemporarily(.screenshot, for: 2.0, thenReturn: returnState)
  }
  
  func applicationWillTerminate(_ notification: Notification) {
    eventMonitor.stop()
    screenshotKeyMonitor.stop()
    accessibilityManager.stop()
    xcodeMonitor.stop()
    overlayController.stop()
  }
}
