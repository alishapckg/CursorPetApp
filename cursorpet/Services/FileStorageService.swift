import Foundation

final class FileStorageService {
  static let shared = FileStorageService()
  
  private let fileManager = FileManager.default
  private var applicationSupportDirectory: URL?
  
  private init() {
    setupDirectory()
  }
  
  // MARK: - Public API
  
  func getCustomFileURL(for state: BuddyState) -> URL? {
    guard let path = UserDefaults.standard.string(forKey: state.userDefaultsForCustomFileKey) else {
      return nil
    }
    
    guard fileManager.fileExists(atPath: path) else {
      resetCustomFile(for: state)
      return nil
    }
    
    return URL(fileURLWithPath: path)
  }
  
  func setCustomFile(url: URL, for state: BuddyState) {
    guard let destinationDir = applicationSupportDirectory else {
      print("❌ Failed to get Application Support folder")
      return
    }
    
    let fileExtension = url.pathExtension.isEmpty ? "gif" : url.pathExtension
    let destinationURL = destinationDir.appendingPathComponent("\(state.rawValue).\(fileExtension)")
    
    do {
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }
      
      try fileManager.copyItem(at: url, to: destinationURL)
      
      UserDefaults.standard.set(destinationURL.path, forKey: state.userDefaultsForCustomFileKey)
      print("✅ File copied to \(destinationURL.path)")
      
    } catch {
      print("❌ Error copying file: \(error.localizedDescription)")
    }
  }
  
  func resetCustomFile(for state: BuddyState) {
    UserDefaults.standard.removeObject(forKey: state.userDefaultsForCustomFileKey)
    
    if let dir = applicationSupportDirectory {
      try? fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        .filter { $0.deletingPathExtension().lastPathComponent == state.rawValue }
        .forEach { try? fileManager.removeItem(at: $0) }
    }
  }
  
  // MARK: - Private
  
  private func setupDirectory() {
    guard let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      return
    }
    let appDirectory = url.appendingPathComponent("GIFBuddy")
    
    if !fileManager.fileExists(atPath: appDirectory.path) {
      try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
    }
    applicationSupportDirectory = appDirectory
  }
}
