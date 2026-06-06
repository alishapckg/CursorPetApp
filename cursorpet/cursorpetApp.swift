import SwiftUI

@main
struct cursorpetApp: App {
  
  // instance of app delegate
  // registering app delegate as delegate for nsapplication
  // without this applicationDidFinishLaunching never will be called
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}
