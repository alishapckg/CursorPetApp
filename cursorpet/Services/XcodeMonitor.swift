import AppKit
import Combine

final class XcodeMonitor: ObservableObject {
  
  enum State {
    case notRunning
    case runningInactive
    case runningActive
  }
  
  @Published private(set) var state: State = .notRunning
  
  private var timer: Timer?
  private var lastState: State = .notRunning
  
  func start() {
    checkStatus()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.checkStatus()
    }
    RunLoop.main.add(timer!, forMode: .common)
  }
  
  func stop() {
    timer?.invalidate()
    timer = nil
  }
  
  private func checkStatus() {
    let runningApps = NSWorkspace.shared.runningApplications
    let isRunning = runningApps.contains { $0.bundleIdentifier == "com.apple.dt.Xcode" }
    let isActive = NSWorkspace.shared.frontmostApplication?.bundleIdentifier == "com.apple.dt.Xcode"
    
    let newState: State
    if isRunning && isActive {
      newState = .runningActive
    } else if isRunning {
      newState = .runningInactive
    } else {
      newState = .notRunning
    }
    
    if newState != lastState {
      lastState = newState
      state = newState
      print("🛠 Xcode state: \(newState)")
    }
  }
}
