import Foundation
import Combine

final class BuddyOrchestrator {
  
  // Dependencies
  private let stateManager: StateManager
  private let settings: SettingsServiceProtocol
  private let eventMonitor: EventMonitor
  private let screenshotMonitor: ScreenshotKeyMonitor
  private let xcodeMonitor: XcodeMonitor
  private let accessibilityManager: AccessibilityManager
  
  private var cancellables = Set<AnyCancellable>()
  
  // State Flags
  private var isXcodeDominant = false
  
  init(
    stateManager: StateManager,
    settings: SettingsServiceProtocol,
    eventMonitor: EventMonitor,
    screenshotMonitor: ScreenshotKeyMonitor,
    xcodeMonitor: XcodeMonitor,
    accessibilityManager: AccessibilityManager
  ) {
    self.stateManager = stateManager
    self.settings = settings
    self.eventMonitor = eventMonitor
    self.screenshotMonitor = screenshotMonitor
    self.xcodeMonitor = xcodeMonitor
    self.accessibilityManager = accessibilityManager
    
    setupBindings()
  }
  
  func start() {
    eventMonitor.start()
    accessibilityManager.startMonitoring()
    
    // Xcode monitoring
    if settings.isDevMode {
      xcodeMonitor.start()
    }
    
    if accessibilityManager.isEnabled {
      screenshotMonitor.start()
    }
    
    stateManager.setStateTemporarily(.hello, for: 4.0, thenReturn: .idle)
  }
  
  func stop() {
    eventMonitor.stop()
    screenshotMonitor.stop()
    accessibilityManager.stop()
    xcodeMonitor.stop()
  }
  
  private func setupBindings() {
    // 1. Event Monitor Logic
    eventMonitor.onScrollStart = { [weak self] in
      guard let self = self, !self.isXcodeDominant else { return }
      self.stateManager.setState(.scrolling)
    }
    
    eventMonitor.onScrollEnd = { [weak self] in
      guard let self = self, !self.isXcodeDominant else { return }
      self.stateManager.setState(.idle)
    }
    
    eventMonitor.onIdle = { [weak self] in
      guard let self = self, !self.isXcodeDominant else { return }
      self.stateManager.setState(.idle)
    }
    
    // 2. Screenshot Logic
    screenshotMonitor.onScreenshot = { [weak self] in
      self?.handleScreenshot()
    }
    
    // 3. Xcode Logic
    xcodeMonitor.$state
      .sink { [weak self] state in
        self?.handleXcodeState(state)
      }
      .store(in: &cancellables)
    
    // 4. Accessibility Toggle
    accessibilityManager.$isEnabled
      .dropFirst()
      .sink { [weak self] isEnabled in
        isEnabled ? self?.screenshotMonitor.start() : self?.screenshotMonitor.stop()
      }
      .store(in: &cancellables)
    
    // 5. Settings Change (Dev Mode Toggle, etc.)
    settings.publisher
      .sink { [weak self] _ in
        self?.handleSettingsChange()
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Logic Handlers
  
  private func handleXcodeState(_ state: XcodeMonitor.State) {
    guard settings.isDevMode else {
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
      guard stateManager.currentState != .screenshot,
            stateManager.currentState != .hello else { return }
      stateManager.setStateTemporarily(.xcodeHappy, for: 3.0, thenReturn: .idle)
    }
  }
  
  private func handleScreenshot() {
    guard stateManager.currentState != .screenshot else { return }
    
    let returnState: BuddyState = (settings.isDevMode && xcodeMonitor.state == .runningInactive)
    ? .xcodeAngry
    : .idle
    
    stateManager.setStateTemporarily(.screenshot, for: 2.0, thenReturn: returnState)
  }
  
  private func handleSettingsChange() {
    // reacting on turning on/off dev mode
    if settings.isDevMode {
      if xcodeMonitor.state == .notRunning {
        xcodeMonitor.start()
      }
    } else {
      xcodeMonitor.stop()
      if stateManager.currentState == .xcodeAngry || stateManager.currentState == .xcodeHappy {
        stateManager.setState(.idle)
      }
    }
    
    handleXcodeState(xcodeMonitor.state)
  }
}
