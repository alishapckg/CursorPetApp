import Foundation

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
