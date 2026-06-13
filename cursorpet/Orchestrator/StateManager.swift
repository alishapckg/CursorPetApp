import Foundation
import Combine

final class StateManager: ObservableObject {
  @Published private(set) var currentState: BuddyState = .idle
  
  private var isPlayingOnce = false
  private let fileStorage = FileStorageService.shared
  
  var onStateChange: ((BuddyState, BuddyContent) -> Void)?
  
  func setState(_ state: BuddyState) {
    guard !isPlayingOnce else { return }
    guard state != currentState else { return }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      if self.currentState != state {
        self.currentState = state
        self.notifyChange()
      }
    }
  }
  
  func setStateTemporarily(_ state: BuddyState, for duration: TimeInterval, thenReturn returnState: BuddyState = .idle) {
    isPlayingOnce = true
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.currentState = state
      self.notifyChange()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
      guard let self = self else { return }
      self.isPlayingOnce = false
      
      if self.currentState == state {
        self.setState(returnState)
      }
    }
  }
  
  func content(for state: BuddyState) -> BuddyContent {
    // 1. checking custom file
    if let customURL = fileStorage.getCustomFileURL(for: state) {
      switch customURL.pathExtension.lowercased() {
      case "lottie", "json":
        return .lottie(url: customURL)
      default:
        return .gif(url: customURL)
      }
    }
    
    // 2. no custom, getting default from bundle
    return .bundleGIF(name: state.defaultGifName)
  }
  
  private func notifyChange() {
    let content = content(for: currentState)
    onStateChange?(currentState, content)
  }
}
