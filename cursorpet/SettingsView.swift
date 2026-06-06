import SwiftUI

struct SettingsView: View {
  @AppStorage("dotSize") var dotSize: Double = 12
  
  // saving rgb as three digits because cant save NSColor or Color directly
  @AppStorage("dotColorRed") var red: Double = 1
  @AppStorage("dotColorGreen") var green: Double = 0
  @AppStorage("dotColorBlue") var blue: Double = 0
  
  
  var body: some View {
    Form {
      Section("Appearance") {
        HStack {
          Text("dot size")
          Slider(value: $dotSize, in: 6...30, step: 1)
          Text("\(Int(dotSize)) px")
            .monospacedDigit()
            .frame(width: 40)
        }
        
        HStack {
          Text("Color")
          Spacer()
          Circle()
            .fill(Color(red: red, green: green, blue: blue))
            .frame(width: 20, height: 20)
        }
        
        HStack {
          Text("Red")
          Slider(value: $red, in: 0...1)
        }
        
        HStack {
          Text("Green")
          Slider(value: $green, in: 0...1)
        }
        
        HStack {
          Text("blue")
          Slider(value: $blue, in: 0...1)
        }
      }
    }
    .padding()
    .frame(width: 360, height: 360)
  }
}
