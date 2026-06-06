import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
  
  // icon in menu bar
  var statusItem: NSStatusItem?
  
  // overlay with our dot
  var overlayController: OverlayController?
  
  // same as viewDidLoad for UIViewController
  // system calls this methods when app is loaded
  func applicationDidFinishLaunching(_ notification: Notification) {
    setupMenuBar()
    overlayController = OverlayController()
    overlayController?.start()
  }
  
  private func setupMenuBar() {
    // width of icon is flexible to size
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // using if let cause button can be nil if system didnt get enough space for icon
    if let button = statusItem?.button {
      button.title = "D"
    }
    
    // menu when clicking
    let menu = NSMenu()
    // maybe remove hot keys?
    menu.addItem(NSMenuItem(title: "On / off", action: #selector(toggleDot), keyEquivalent: "t"))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Logout", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    statusItem?.menu = menu
    
    //didChangeOcclusionStateNotification comes when window is visible / hidden
    NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification, object: nil, queue: .main) { [weak self] _ in
      self?.overlayController?.applySettings()
    }
  }
  
  @objc private func toggleDot() {
    overlayController?.toggle()
  }
  
  @objc private func openSettings() {
    let settingsView = SettingsView()
    let hostingController = NSHostingController(rootView: settingsView)
    let window = NSWindow(contentViewController: hostingController)
    window.title = "Cursot Dot - Settings"
    window.styleMask = [.titled, .closable]
    window.center()
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}
