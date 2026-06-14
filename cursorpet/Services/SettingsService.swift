import Foundation
import Combine

protocol SettingsServiceProtocol {
  var overlaySize: CGFloat { get }
  var overlayOffset: CGPoint { get }
  var isDevMode: Bool { get }
  var publisher: NotificationCenter.Publisher { get }
}

final class SettingsService: SettingsServiceProtocol {
  static let shared = SettingsService()
  
  private let userDefaults = UserDefaults.standard
  
  var publisher: NotificationCenter.Publisher {
    NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
  }
  
  var overlaySize: CGFloat {
    CGFloat(userDefaults.double(forKey: "overlaySize"))
  }
  
  var overlayOffset: CGPoint {
    let x = userDefaults.double(forKey: "offsetX")
    let y = userDefaults.double(forKey: "offsetY")
    return CGPoint(x: x, y: y)
  }
  
  var isDevMode: Bool {
    userDefaults.bool(forKey: "devMode")
  }
}
