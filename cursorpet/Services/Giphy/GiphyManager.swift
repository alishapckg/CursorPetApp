import Foundation
import Combine

// trending
// search
@MainActor
final class GiphyManager: ObservableObject {
  
  private(set) var trendingGifs: [GiphyItem] = []
  
  init() {}
  
  func fetchTrendingGifs() async throws -> [GiphyItem] {
    let baseURL = "https://api.giphy.com/v1/gifs/trending"
    
    return []
  }
}
