import AppKit

final class DotView: NSView {
  var color: NSColor = .systemRed {
    
    // calling every time when changes
    // needsDisplay as signal to system - redraw me
    didSet { needsDisplay = true }
  }
  
  var size: CGFloat = 12 {
    didSet {
      frame.size = CGSize(width: size, height: size)
      needsDisplay = true
    }
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    // wantsLayer - true - turning on CALayer under this view
    // we need it to make background of view to really opaque
    // without wantsLayer view can draw system background
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // dirtyRect is the part of view that needs to be updated
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    let inset: CGFloat = 1
    let rect = bounds.insetBy(dx: inset, dy: inset)
    context.setFillColor(color.cgColor)
    context.fillEllipse(in: rect)
    
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.6).cgColor)
    context.setLineWidth(1)
    context.strokeEllipse(in: rect)
  }
}
