import Foundation

// modes
// hello when opened - done need to fix timing
// not in xcode (if xcode is active and installed app) - angry
// xcode project build success - happy
// xcode project build fail - sad
// xcode project building - building
// scrolling - reading - done
// idle - when nothing happes - no scroll, no xcode building - no typing - thinking
// main mode - just on laptop  - done
enum BuddyState: String, CaseIterable {
  case idle = "idle"
  case hello = "hello"
  case scrolling = "scrolling"
  
  // in settings
  var displayName: String {
    switch self {
    case .idle:
      return "No movement"
    case .hello:
      return "Greetings"
    case .scrolling:
      return "Scrolling"
    }
  }
  
  // in settings
  var description: String {
    switch self {
    case .idle:
      return "Not active more than 5 sec"
    case .hello:
      return "Activating the app, 2 seconds"
    case .scrolling:
      return "When user scrolls"
    }
  }
  
  // installed gif name - default if user didnt make his own
  var defaultGifName: String {
    switch self {
    case .idle:
      return "buddy_loading"
    case .hello:
      return "buddy_hello"
    case .scrolling:
      return "buddy_scrolling"
    }
  }
  
  var userDefaultsForCustomFileKey: String {
    return "customFile_\(rawValue)"
  }
}
