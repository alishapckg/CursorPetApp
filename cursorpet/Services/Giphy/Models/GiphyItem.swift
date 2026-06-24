import Foundation

struct GiphyItem: Decodable, Identifiable {
  let id: String
  let title: String
  let username: String?
  let images: GiphyImages
  let url: String?
}

struct GiphyImageInfo: Decodable {
  let url: String?
  let width: String?
  let height: String?
  let size: String?
}

struct GiphyMeta: Decodable {
  let status: Int
  let msg: String
}

struct GiphyPagination: Decodable {
  let totalCount: Int?
  let count: Int?
  let offset: Int?

  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case count
    case offset
  }
}
