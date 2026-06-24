import Foundation

struct GiphySearchResponse: Decodable {
  let data: [GiphyItem]
  let meta: GiphyMeta
  let pagination: GiphyPagination?
}
