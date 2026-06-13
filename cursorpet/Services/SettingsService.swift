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
    CGFloat(userDefaults.double(forKey: "overlaySize").nonZero ?? 64)
  }
  
  var overlayOffset: CGPoint {
    let x = userDefaults.double(forKey: "offsetX").nonZero ?? 16
    let y = userDefaults.double(forKey: "offsetY").nonZero ?? 8
    return CGPoint(x: x, y: y)
  }
  
  var isDevMode: Bool {
    userDefaults.bool(forKey: "devMode")
  }
}

private extension Double {
  var nonZero: Double? { self == 0 ? nil : self }
}
