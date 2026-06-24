import Foundation

struct GiphyImages: Decodable {
  let original: GiphyImageInfo
  let fixedWidth: GiphyImageInfo?
  let downsized: GiphyImageInfo?

  enum CodingKeys: String, CodingKey {
    case original
    case fixedWidth = "fixed_width"
    case downsized
  }
}
