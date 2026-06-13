import Foundation
import Combine

final class StateManager: ObservableObject {
  @Published private(set) var currentState: BuddyState = .idle
  
  private var isPlayingOnce = false
  
  var onStateChange: ((BuddyState, BuddyContent) -> Void)?
  
  func setState(_ state: BuddyState) {
    guard !isPlayingOnce else { return }
    guard state != currentState else { return }
    currentState = state
    notifyChange()
  }
  
  func setStateTemporarily(_ state: BuddyState, for duration: TimeInterval, thenReturn returnState: BuddyState = .idle) {
    isPlayingOnce = true
    currentState = state
    notifyChange()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
      guard let self else { return }
      self.isPlayingOnce = false
      if self.currentState == state {
        self.setState(returnState)
      }
    }
  }
  
  func content(for state: BuddyState) -> BuddyContent {
//    switch state {
//    case .screenshot:
//      return .emoji("📸")
//    case .xcodeHappy:
//      return .emoji("😊")
//    case .xcodeAngry:
//      return .emoji("😩")
//    default:
//      break
//    }
    
    guard let path = UserDefaults.standard.string(forKey: state.userDefaultsForCustomFileKey) else {
      return .bundleGIF(name: state.defaultGifName)
    }
    
    let url = URL(fileURLWithPath: path)
    
    guard FileManager.default.fileExists(atPath: path) else {
      UserDefaults.standard.removeObject(forKey: state.userDefaultsForCustomFileKey)
      return .bundleGIF(name: state.defaultGifName)
    }
    
    switch url.pathExtension.lowercased() {
    case "lottie", "json":
      return .lottie(url: url)
    default:
      return .gif(url: url)
    }
  }
  
  func setCustomFile(url: URL, for state: BuddyState) {
    guard let destinationDir = getApplicationSupportDirectory() else {
      print("Failed to get access to Application Support folder")
      return
    }
    
    let fileExtension = url.pathExtension.isEmpty ? "gif" : url.pathExtension
    let destinationURL = destinationDir.appendingPathComponent("\(state.rawValue).\(fileExtension)")
    
    do {
      if FileManager.default.fileExists(atPath: destinationURL.path) {
        try FileManager.default.removeItem(at: destinationURL)
      }
      try FileManager.default.copyItem(at: url, to: destinationURL)
      print("File copied to \(destinationURL.path)")
      UserDefaults.standard.set(destinationURL.path, forKey: state.userDefaultsForCustomFileKey)
      
      if state == currentState {
        notifyChange()
      }
    } catch {
      print("Error copying file \(error.localizedDescription)")
    }
  }
  
  func resetToDefault(for state: BuddyState) {
    UserDefaults.standard.removeObject(forKey: state.userDefaultsForCustomFileKey)
    
    if let dir = getApplicationSupportDirectory() {
      let fileURL = dir.appendingPathComponent(state.rawValue)
    }
    
    if state == currentState {
      notifyChange()
    }
  }
  
  func hasCustomFile(for state: BuddyState) -> Bool {
    guard let path = UserDefaults.standard.string(forKey: state.userDefaultsForCustomFileKey) else {
      return false
    }
    return FileManager.default.fileExists(atPath: path)
  }
  
  private func notifyChange() {
    let content = content(for: currentState)
    onStateChange?(currentState, content)
  }
  
  private func getApplicationSupportDirectory() -> URL? {
    let fileManager = FileManager.default
    if let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let appDirectory = url.appendingPathComponent("GIFBuddy")
      if !fileManager.fileExists(atPath: appDirectory.path) {
        try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
      }
      return appDirectory
    }
    return nil
  }
}
