import Foundation
import Combine

final class StateManager: ObservableObject {
  @Published private(set) var currentState: BuddyState = .idle
  
  // callback for overlay controller - what to show
  var onStateChange: ((BuddyState, BuddyContent) -> Void)?
  
  // to set state forever
  func setState(_ state: BuddyState) {
    guard state != currentState else { return }
    currentState = state
    notifyChange()
  }
  
  func setStateTemporarily(_ state: BuddyState, for duration: TimeInterval, thenReturn returnState: BuddyState = .idle) {
    currentState = state
    notifyChange()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
      guard let self else { return }
      if self.currentState == state {
        self.setState(returnState)
      }
      
    }
  }
  
  func content(for state: BuddyState) -> BuddyContent {
    // if there is custom file in UserDefaults
    if let path = UserDefaults.standard.string(forKey: state.userDefaultsForCustomFileKey) {
      let url = URL(fileURLWithPath: path)
      
      // checking if the file is existing on disk
      // user could delete or move it
      guard FileManager.default.fileExists(atPath: path) else {
        // if file is deleted - we remove it from settings and use default file
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
    
    // if no custom file - using default
    return .bundleGIF(name: state.defaultGifName)
  }
  
  func setCustomFile(url: URL, for state: BuddyState) {
    UserDefaults.standard.set(url.path, forKey: state.userDefaultsForCustomFileKey)
    
    if state == currentState {
      notifyChange()
    }
  }
  
  func resetToDefault(for state: BuddyState) {
    UserDefaults.standard.removeObject(forKey: state.userDefaultsForCustomFileKey)
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
}
