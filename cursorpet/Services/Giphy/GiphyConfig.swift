import Foundation

enum GiphyConfig {
  static var apiKey: String {
    guard let key = ProcessInfo.processInfo.environment["GIPHY_API_KEY"], !key.isEmpty else {
      fatalError("GIPHY_API_KEY is not set. Copy Secrets.xcconfig.example to Secrets.xcconfig and set GIPHY_API_KEY")
    }
    return key
  }
}
