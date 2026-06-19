import Foundation

struct GiphyItem: Decodable, Identifiable {
  let id: String
  let title: String
  let username: String?
  let images: GiphyImages
  let url: String?
}
