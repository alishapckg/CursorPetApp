import AppKit
import Lottie

final class BuddyView: NSView {
  private var gifView: GIFPlayerView?
  
  private var lottieView: LottieAnimationView?
  
  func show(_ content: BuddyContent) {
    switch content {
    case .bundleGIF(let name):
      showGIF(named: name)
    case .gif(let url):
      showGIF(url: url)
      
    case .lottie(let url):
      showLottie(url: url)
    }
  }
  
  private func showGIF(named name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "gif") else {
      print("buddy view not found with name \(name)")
      return
    }
    
    showGIF(url: url)
  }
  
  private func showGIF(url: URL) {
    removeLottie()
    
    if gifView == nil {
      let gv = GIFPlayerView(frame: bounds)
      gv.autoresizingMask = [.width, .height]
      addSubview(gv)
      self.gifView = gv
    }
    
    self.gifView?.load(url: url)
  }
  
  private func showLottie(url: URL) {
    removeGIF()
    
    removeLottie()
    
    let lv = LottieAnimationView(filePath: url.path)
    lv.frame = bounds
    lv.autoresizingMask = [.width, .height]
    
    lv.contentMode = .scaleAspectFit
    
    lv.loopMode = .loop
    
    lv.backgroundBehavior = .pauseAndRestore
    
    addSubview(lv)
    lottieView = lv
    lv.play()
  }
  
  private func removeGIF() {
    gifView?.stop()
    gifView?.removeFromSuperview()
    gifView = nil
  }
  
  private func removeLottie() {
    lottieView?.stop()
    lottieView?.removeFromSuperview()
    lottieView = nil
  }
  
  func stopAll() {
    removeGIF()
    removeLottie()
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
