import SwiftUI
import AppKit

struct MouseTrackingView: NSViewRepresentable {
  var onMouseMoved: ((CGPoint) -> Void)
  
  func makeNSView(context: Context) -> TrackingNSView {
    let view = TrackingNSView()
    view.onMouseMoved = onMouseMoved
    return view
  }
  
  func updateNSView(_ nsView: TrackingNSView, context: Context) {
    nsView.onMouseMoved = onMouseMoved
  }
}

final class TrackingNSView: NSView {
  var onMouseMoved: ((CGPoint) -> Void)?
  
  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    trackingAreas.forEach { removeTrackingArea($0) }
    
    let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
    addTrackingArea(trackingArea)
  }
  
  override func mouseMoved(with event: NSEvent) {
    onMouseMoved?(event.locationInWindow)
  }
}
