import AppKit
import SwiftUI

final class StatusBarController {
  private var statusItem: NSStatusItem?
  private weak var stateManager: StateManager?
  private weak var overlayController: OverlayController?
  private var settingsWindow: NSWindow?
  private var accessibilityManager: AccessibilityManager?
  
  init(stateManager: StateManager, overlayController: OverlayController, accessibilityManager: AccessibilityManager) {
    self.stateManager = stateManager
    self.overlayController = overlayController
    self.accessibilityManager = accessibilityManager
    setup()
  }
  
  private func setup() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem?.button?.title = "🐾"
    statusItem?.menu = makeMenu()
  }
  
  private func makeMenu() -> NSMenu {
    let menu = NSMenu()
    menu.addItem(withTitle: "Show / Hide", action: #selector(toggleVisibility), keyEquivalent: "h").target = self
    menu.addItem(.separator())
    menu.addItem(withTitle: "Settings...", action: #selector(openSettings), keyEquivalent: ",").target = self
    menu.addItem(.separator())
    menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    return menu
  }
  
  @objc private func toggleVisibility() {
    overlayController?.toggle()
  }
  
  @objc private func openSettings() {
    if let existing = settingsWindow, existing.isVisible {
      existing.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
      return
    }
    
    guard let stateManager, let accessibilityManager else { return }
    
    let view = SettingsView(stateManager: stateManager, accessibilityManager: accessibilityManager)
    let controller = NSHostingController(rootView: view)
    let window = NSWindow(contentViewController: controller)
    
    window.title = ""
    window.styleMask = [.titled, .closable, .fullSizeContentView]
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.appearance = NSAppearance(named: .darkAqua)
    window.isMovableByWindowBackground = true
    
    // position below the status bar icon
    // need to layout first so frame.size is known
    window.layoutIfNeeded()
    
    if let button = statusItem?.button,
       let buttonWindow = button.window {
      let buttonRect = buttonWindow.convertToScreen(button.frame)
      let x = buttonRect.midX - window.frame.width / 2
      let y = buttonRect.minY - window.frame.height - 4
      window.setFrameOrigin(NSPoint(x: x, y: y))
    } else {
      window.center()
    }
    
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
    settingsWindow = window
  }
}
