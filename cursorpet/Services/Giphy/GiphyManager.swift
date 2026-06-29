import Foundation
import Combine

@MainActor
final class GiphyManager: ObservableObject {
  @Published var trendingGifs: [GiphyItem] = []
  @Published var searchResults: [GiphyItem] = []
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var error: String?

  private(set) var hasMoreTrending = true
  private(set) var hasMoreSearch = true

  private var trendingOffset = 0
  private var searchOffset = 0
  private var currentQuery = ""

  private let limit = 25
  private let session: URLSession
  private let decoder: JSONDecoder
  private let apiKey: String

  init(apiKey: String? = nil) {
    self.apiKey = apiKey ?? GiphyConfig.apiKey
    self.session = URLSession.shared
    self.decoder = JSONDecoder()
  }

  func fetchTrending() async {
    trendingOffset = 0
    hasMoreTrending = true
    isLoading = true
    error = nil

    await perform(.trending, offset: 0)

    isLoading = false
  }

  func loadMoreTrending() async {
    guard !isLoadingMore, hasMoreTrending else { return }
    isLoadingMore = true

    trendingOffset += limit
    let startCount = trendingGifs.count
    await perform(.trending, offset: trendingOffset)

    hasMoreTrending = trendingGifs.count > startCount
    isLoadingMore = false
  }

  func search(query: String) async {
    currentQuery = query
    searchOffset = 0
    hasMoreSearch = true
    isLoading = true
    error = nil

    await perform(.search(query: query), offset: 0)

    isLoading = false
  }

  func loadMoreSearch() async {
    guard !isLoadingMore, hasMoreSearch, !currentQuery.isEmpty else { return }
    isLoadingMore = true

    searchOffset += limit
    let startCount = searchResults.count
    await perform(.search(query: currentQuery), offset: searchOffset)

    hasMoreSearch = searchResults.count > startCount
    isLoadingMore = false
  }

  // MARK: - Private

  private enum Endpoint {
    case trending
    case search(query: String)

    var url: String {
      switch self {
      case .trending: return "https://api.giphy.com/v1/gifs/trending"
      case .search:   return "https://api.giphy.com/v1/gifs/search"
      }
    }

    var queryItemName: String? {
      switch self {
      case .trending: return nil
      case .search:   return "q"
      }
    }

    var queryValue: String? {
      switch self {
      case .trending: return nil
      case .search(let q): return q
      }
    }
  }

  private func perform(_ endpoint: Endpoint, offset: Int) async {
    var components = URLComponents(string: endpoint.url)!
    var items: [URLQueryItem] = [
      .init(name: "api_key", value: apiKey),
      .init(name: "limit", value: "\(limit)"),
      .init(name: "offset", value: "\(offset)"),
      .init(name: "rating", value: "g"),
      .init(name: "bundle", value: "messaging_non_clips"),
    ]
    if let name = endpoint.queryItemName, let val = endpoint.queryValue {
      items.append(.init(name: name, value: val))
    }
    components.queryItems = items

    do {
      let (data, _) = try await session.data(from: components.url!)
      let response = try decoder.decode(GiphySearchResponse.self, from: data)
      let isAppend = offset > 0

      switch endpoint {
      case .trending:
        if isAppend {
          trendingGifs += response.data
          hasMoreTrending = response.data.count >= limit
        } else {
          trendingGifs = response.data
          hasMoreTrending = response.data.count >= limit
        }
      case .search:
        if isAppend {
          searchResults += response.data
          hasMoreSearch = response.data.count >= limit
        } else {
          searchResults = response.data
          hasMoreSearch = response.data.count >= limit
        }
      }
    } catch {
      self.error = error.localizedDescription
      isLoading = false
      isLoadingMore = false
    }
  }
}
