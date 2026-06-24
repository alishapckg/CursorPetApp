import Foundation
import Combine

@MainActor
final class GiphyManager: ObservableObject {
  @Published var trendingGifs: [GiphyItem] = []
  @Published var searchResults: [GiphyItem] = []
  @Published var isLoading = false
  @Published var error: String?

  private let session: URLSession
  private let decoder: JSONDecoder
  private let apiKey: String

  init(apiKey: String? = nil) {
    self.apiKey = apiKey ?? GiphyConfig.apiKey
    self.session = URLSession.shared
    self.decoder = JSONDecoder()
  }

  func fetchTrending(limit: Int = 25, offset: Int = 0) async {
    isLoading = true
    error = nil

    var components = URLComponents(string: "https://api.giphy.com/v1/gifs/trending")!
    components.queryItems = [
      .init(name: "api_key", value: apiKey),
      .init(name: "limit", value: "\(limit)"),
      .init(name: "offset", value: "\(offset)"),
      .init(name: "rating", value: "g"),
      .init(name: "bundle", value: "messaging_non_clips"),
    ]

    do {
      let (data, _) = try await session.data(from: components.url!)
      let response = try decoder.decode(GiphySearchResponse.self, from: data)
      trendingGifs = response.data
    } catch {
      self.error = error.localizedDescription
    }

    isLoading = false
  }

  func search(query: String, limit: Int = 25, offset: Int = 0) async {
    isLoading = true
    error = nil

    var components = URLComponents(string: "https://api.giphy.com/v1/gifs/search")!
    components.queryItems = [
      .init(name: "api_key", value: apiKey),
      .init(name: "q", value: query),
      .init(name: "limit", value: "\(limit)"),
      .init(name: "offset", value: "\(offset)"),
      .init(name: "rating", value: "g"),
      .init(name: "bundle", value: "messaging_non_clips"),
    ]

    do {
      let (data, _) = try await session.data(from: components.url!)
      let response = try decoder.decode(GiphySearchResponse.self, from: data)
      searchResults = response.data
    } catch {
      self.error = error.localizedDescription
    }

    isLoading = false
  }
}
