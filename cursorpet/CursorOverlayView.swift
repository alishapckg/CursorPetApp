import AppKit

enum BuddyContent {
  case bundleGIF(name: String) // gif file name from bundle
  case gif(url: URL) // gif on disk - maybe no need
  case lottie(url: URL) // static image
}

