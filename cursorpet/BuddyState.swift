import Foundation

enum BuddyContent {
  case bundleGIF(name: String) // gif file name from bundle
  case gif(url: URL) // gif on disk - maybe no need
  case lottie(url: URL) // static image
  case emoji(String)
}

// modes
// DONE hello when opened - done need to fix timing
// not in xcode (if xcode is active and installed app) - angry
// xcode project build success - happy
// xcode project build fail - sad
// xcode project building - building
// DONE scrolling - reading - done
// idle - when nothing happes - no scroll, no xcode building - no typing - thinking
// DONE main mode - just on laptop  - done
enum BuddyState: String, CaseIterable {
  case idle = "idle"
  case hello = "hello"
  case scrolling = "scrolling"
  case screenshot = "screenshot"
  case xcodeHappy = "xcodeHappy"   // ← Xcode активен, пользователь в нём
  case xcodeAngry = "xcodeAngry" // ← Xcode запущен, но пользователь в другом окне
  
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
    case .screenshot: return "buddy_hello"
    case .xcodeHappy: return "buddy_hello"
    case .xcodeAngry: return "buddy_hello"
    }
  }
  
  var userDefaultsForCustomFileKey: String {
    return "customFile_\(rawValue)"
  }
}
