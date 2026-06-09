import SwiftUI

struct SettingsView: View {
  @ObservedObject var stateManager: StateManager
  
  @AppStorage("overlaySize") var size: Double = 128
  
  // saving rgb as three digits because cant save NSColor or Color directly
  @AppStorage("offsetX") var offsetX: Double = 16
  @AppStorage("offsetY") var offsetY: Double = 8
  
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("🐾 GIFBuddy Settings")
          .font(.title2.bold())
        
        Spacer()
      }
      .padding([.horizontal, .top], 20)
      .padding(.bottom, 12)
      
      Divider()
      
      VStack(spacing: 0) {
        ForEach(BuddyState.allCases, id: \.self) { state in
          StateRow(state: state, stateManager: stateManager)
          
          if state != BuddyState.allCases.last {
            Divider()
              .padding(.leading, 20)
          }
        }
      }
      
      Divider()
      
      VStack(alignment: .leading, spacing: 12) {
        Text("Position and size")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        HStack {
          Text("Size")
          Slider(value: $size, in: 32...128, step: 8)
          Text("\(Int(size))px")
            .monospacedDigit()
            .frame(width: 45)
        }
        
        HStack {
          Text("Offset →")
          Slider(value: $offsetX, in: -20...80, step: 4)
          Text("\(Int(offsetX))px")
            .monospacedDigit()
            .frame(width: 45)
        }
        
        HStack {
          Text("Offset ↑")
          Slider(value: $offsetY, in: -20...80, step: 4)
          Text("\(Int(offsetY))px")
            .monospacedDigit()
            .frame(width: 45)
        }
      }
      .padding(20)
    }
    .frame(width: 420)
  }
}
