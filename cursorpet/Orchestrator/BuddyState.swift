import Foundation

enum BuddyContent {
  case bundleGIF(name: String)
  case gif(url: URL)
  case emoji(String) // need to remove
}

enum BuddyState: String, CaseIterable, Identifiable {
  var id: String { rawValue }
  case idle = "idle"
  case hello = "hello"
  case scrolling = "scrolling"
  case screenshot = "screenshot"
  case xcodeHappy = "xcodeHappy"
  case xcodeAngry = "xcodeAngry"
//  case typing = "typing"
//  case longIdle = "longIdle"
//  case lowBattery = "lowBattery"
  
  var displayName: String {
    switch self {
    case .idle: return "No movement"
    case .hello: return "Greetings"
    case .scrolling: return "Scrolling"
    case .screenshot: return "Screenshot"
    case .xcodeHappy: return "Xcode focused"
    case .xcodeAngry: return "Xcode background"
//    case .typing: return "Typing"
//    case .longIdle: return "No movement for > 2 min"
//    case .lowBattery: return "Low charge"
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
//    case .typing: return "When typing on the keyboard"
//    case .longIdle: return "Not active more than 2 min"
//    case .lowBattery: return "Charge lower than 25%"
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
//    case .typing: return "buddy_typing"
//    case .longIdle: return "buddy_long_idle"
//    case .lowBattery: return "buddy_low_charge"
    }
  }
  
  var userDefaultsForCustomFileKey: String {
    return "customFile_\(rawValue)"
  }
}
