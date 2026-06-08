import AppKit
import ImageIO
// publish gif playing for macos project
final class GIFPlayerView: NSView {
  private var frames: [CGImage] = []
  private var delays: [TimeInterval] = []
  private var currentFrame = 0
  private var timer: Timer?
  private var currentURL: URL?
  
  // loading gif from file
  func load(url: URL) {
    guard url != currentURL else { return }
    currentURL = url
    stop()
    
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return }
    let count = CGImageSourceGetCount(source)
    for i in 0..<count {
      guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
      frames.append(image)
      delays.append(frameDelay(source: source, index: i))
    }
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
    
    if let delay = gifProps[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval, delay > 0.02 {
      return delay
    }
    
    if let delay = gifProps[kCGImagePropertyGIFDelayTime as String] as? TimeInterval, delay > 0.02 {
      return delay
    }
    return 0.1
  }
  
  private func play() {
    guard !frames.isEmpty else { return }
    showFrame(0)
  }
  
  private func showFrame(_ index: Int) {
    currentFrame = index % frames.count
    needsDisplay = true
    
    timer?.invalidate()
    
    let delay = delays.indices.contains(currentFrame) ? delays[currentFrame] : 0.1
    
    timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
      guard let self else { return }
      self.showFrame(self.currentFrame + 1)
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
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit { stop() }
  
  func stop() {
    timer?.invalidate()
    timer = nil
    frames = []
    delays = []
    currentFrame = 0
    currentURL = nil
    needsDisplay = true
  }
  
  func pause() {
    timer?.invalidate()
  }
  
  func resume() {
    play()
  }
}
