import AppKit
import SwiftUI

final class StatusBarController {
  private var statusItem: NSStatusItem?
  private weak var stateManager: StateManager?
  private weak var overlayController: OverlayController?
  private var settingsWindow: NSWindow?
  
  init(stateManager: StateManager, overlayController: OverlayController) {
    self.stateManager = stateManager
    self.overlayController = overlayController
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
    menu.addItem(withTitle: "Logout", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    return menu
  }
  
  @objc private func toggleVisibility() {
    overlayController?.toggle()
  }
  
  @objc private func openSettings() {
    guard let stateManager else { return }
    
    let view = SettingsView(stateManager: stateManager)
    let controller = NSHostingController(rootView: view)
    let window = NSWindow(contentViewController: controller)
    
    window.title = "GIFBuddy"
    window.styleMask = [.titled, .closable]
    window.center()
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
    settingsWindow = window
  }
}
