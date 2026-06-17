import Foundation

struct GiphyItem: Codable {
  let type: String
  let id: String
  let slug: String // unique url for gif
  let username: String
  let content: String
}
