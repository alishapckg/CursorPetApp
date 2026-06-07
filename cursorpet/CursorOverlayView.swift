import AppKit

enum CursorContent {
  case shape(DotShape)
  case gif(String) // gif file name from bundle
  case gifURL(URL) // gif on disk - maybe no need
  case image(NSImage) // static image
}

final class CursorOverlayView: NSView {
  var content: CursorContent = .shape(.cirle) {
    didSet { applyContent() }
  }
  
  var color: NSColor = .systemRed {
    didSet { needsDisplay = true }
  }
  
  var size: CGFloat = 12 {
    didSet {
      frame.size = CGSize(width: size, height: size)
      gifView?.frame = bounds
      needsDisplay = true
    }
  }
  
  private var gifView: GIFPlayerView?
  private var staticImageView: NSImageView?
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func applyContent() {
    gifView?.stop()
    gifView?.removeFromSuperview()
    gifView = nil
    staticImageView?.removeFromSuperview()
    staticImageView = nil
    
    switch content {
    case .shape:
      needsDisplay = true
      
    case .gif(let name):
      setupGIFView()
      gifView?.load(named: name)
      
    case .gifURL(let url):
      setupGIFView()
      gifView?.load(url: url)
      
    case .image(let nsImage):
      let iv = NSImageView(frame: bounds)
      iv.image = nsImage
      iv.imageScaling = .scaleProportionallyUpOrDown
      addSubview(iv)
      staticImageView = iv
      needsDisplay = true
    }
  }
  
  private func setupGIFView() {
    let gv = GIFPlayerView(frame: bounds)
    addSubview(gv)
    gifView = gv
  }
  
  override func draw(_ dirtyRect: NSRect) {
    guard case .shape(let shape) = content else { return }
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    
    let inset: CGFloat = 1
    let rect = bounds.insetBy(dx: inset, dy: inset)
    
    context.setFillColor(color.cgColor)
    
    switch shape {
    case .circle:
      context.fillEllipse(in: rect)
      context.setStrokeColor(NSColor.white.withAlphaComponent(0.6).cgColor)
      context.setLineWidth(1)
      context.strokeEllipse(in: rect)
      
    case .square:
      let path = CGPath(roundedRect: rect, cornerWidth: 3, cornerHeight: 3, transform: nil)
      context.addPath(path)
      context.fillPath()
      context.setStrokeColor(NSColor.white.withAlphaComponent(0.6).cgColor)
      context.setLineWidth(1)
      context.addPath(path)
      context.strokePath()
    }
  }
}
