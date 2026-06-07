import AppKit
import ImageIO
// publish gif playing for macos project
final class GIFPlayerView: NSView {
  private var frames: [CGImage] = []
  private var delays: [TimeInterval] = []
  private var currentFrame = 0
  private var timer: Timer?
  
  // loading gif from file
  func load(url: URL) {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return }
    loadFrames(from: source)
    play()
  }
  
  // loading gif from bundle (installed to the app)
  func load(named name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "gif") else {
      print("GIF NOT FOUND \(name)")
      return
    }
    
    load(url: url)
  }
  
  // loading gif from data (for example downloaded)
  func load(data: Data) {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }
    loadFrames(from: source)
    play()
  }
  
  private func loadFrames(from source: CGImageSource) {
    frames = []
    delays = []
    
    let count = CGImageSourceGetCount(source)
    
    for i in 0..<count {
      guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else { return }
      frames.append(image)
      
      let delay = frameDelay(source: source, index: i)
      delays.append(delay)
    }
  }
  
  private func frameDelay(source: CGImageSource, index: Int) -> TimeInterval {
    guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any], let gifProps = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else { return 0.1 }
    
    if let delay = gifProps[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval, delay > 0 {
      return delay
    }
    
    if let delay = gifProps[kCGImagePropertyGIFDelayTime as String] as? TimeInterval, delay > 0 {
      return delay
    }
    return 0.1
  }
  
  private func play() {
    guard !frames.isEmpty else { return }
    timer?.invalidate()
    showFrame(0)
  }
  
  private func showFrame(_ index: Int) {
    currentFrame = index
    needsDisplay = true
    
    let delay = delays.indices.contains(index) ? delays[index] : 0.1
    
    timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
      guard let self else { return }
      let next = (self.currentFrame + 1) % self.frames.count
      self.showFrame(next)
    }
    
    RunLoop.main.add(timer!, forMode: .common)
  }
  
  override func draw(_ dirtyRect: NSRect) {
    guard !frames.isEmpty else { return }
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    let frame = frames[currentFrame]
    
    context.interpolationQuality = .none
    context.draw(frame, in: bounds)
  }
  
  func stop() {
    timer?.invalidate()
  }
  
  func pause() {
    timer?.invalidate()
  }
  
  func resume() {
    play()
  }
}
