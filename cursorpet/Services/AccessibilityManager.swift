import Foundation
import Combine
import ApplicationServices

final class AccessibilityManager: ObservableObject {
  @Published var isEnabled: Bool = false
  
  private var timer: Timer?
  
  func startMonitoring() {
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
    let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false] as CFDictionary
    let newValue = AXIsProcessTrustedWithOptions(options)
    
    if newValue != isEnabled {
      isEnabled = newValue
      print("🔓 Accessibility status changed: \(newValue)")
    }
  }
}
