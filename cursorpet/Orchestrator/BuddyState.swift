import Foundation

enum BuddyContent {
  case bundleGIF(name: String)
  case gif(url: URL)
  case lottie(url: URL)
  case emoji(String)
}

enum BuddyState: String, CaseIterable {
  case idle = "idle"
  case hello = "hello"
  case scrolling = "scrolling"
  case screenshot = "screenshot"
  case xcodeHappy = "xcodeHappy"
  case xcodeAngry = "xcodeAngry"
  
  var displayName: String {
    switch self {
    case .idle: return "No movement"
    case .hello: return "Greetings"
    case .scrolling: return "Scrolling"
    case .screenshot: return "Screenshot"
    case .xcodeHappy: return "Xcode focused"
    case .xcodeAngry: return "Xcode background"
    }
  }
  
  var description: String {
    switch self {
    case .idle: return "Not active more than 5 sec"
    case .hello: return "Activating the app, 5 seconds"
    case .scrolling: return "When user scrolls"
    case .screenshot: return "When taking a screenshot"
    case .xcodeHappy: return "When Xcode is active"
    case .xcodeAngry: return "When Xcode runs but not focused"
    }
  }
  
  var defaultGifName: String {
    switch self {
    case .idle: return "buddy_loading"
    case .hello: return "buddy_hello"
    case .scrolling: return "buddy_scrolling"
    case .screenshot: return "kermit_screenshot"
    case .xcodeHappy: return "buddy_happy"
    case .xcodeAngry: return "buddy_angry"
    }
  }
  
  var userDefaultsForCustomFileKey: String {
    return "customFile_\(rawValue)"
  }
}
