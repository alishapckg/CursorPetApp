import SwiftUI

struct SettingsView: View {
  @ObservedObject var stateManager: StateManager
  
  @AppStorage("overlaySize") var size: Double = 128
  @AppStorage("offsetX")     var offsetX: Double = 16
  @AppStorage("offsetY")     var offsetY: Double = 8
  
  private let bg      = Color(hex: "#141118")
  private let border  = Color.white.opacity(0.08)
  private let label   = Color.white.opacity(0.50)
  private let accent  = Color(hex: "#00FF88")
  private let textSec = Color.white.opacity(0.65)
  
  var body: some View {
    VStack(spacing: 0) {
      
      // Animations
      SectionLabel("Animations", color: label)
      
      VStack(spacing: 4) {
        ForEach(BuddyState.allCases, id: \.self) { state in
          StateRow(state: state, stateManager: stateManager)
        }
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 4)
      
      Divider()
        .overlay(border)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
      
      // Position & size
      SectionLabel("Position & size", color: label)
      
      VStack(spacing: 10) {
        DarkSlider(label: "Size",     value: $size,    range: 32...128, accent: accent)
        DarkSlider(label: "Offset →", value: $offsetX, range: -20...80, accent: accent)
        DarkSlider(label: "Offset ↑", value: $offsetY, range: -20...80, accent: accent)
      }
      .padding(.horizontal, 18)
      
      // Footer
      HStack {
        HStack(spacing: 5) {
          Circle()
            .fill(Color(hex: "#00FF88"))
            .frame(width: 6, height: 6)
          Text("drag GIFs onto cards to swap")
            .font(.system(size: 11))
            .foregroundColor(Color.white.opacity(0.35))
        }
        Spacer()
        Text("v1.0")
          .font(.system(size: 11))
          .foregroundColor(Color.white.opacity(0.28))
      }
      .padding(.horizontal, 18)
      .padding(.top, 10)
      .padding(.bottom, 16)
    }
    .padding(.top, 8)
    .background(bg)
    .frame(width: 440)
  }
}

// Section label
private struct SectionLabel: View {
  let text: String
  let color: Color
  init(_ text: String, color: Color) { self.text = text; self.color = color }
  
  var body: some View {
    HStack {
      Text(text.uppercased())
        .font(.system(size: 11, weight: .medium))
        .kerning(0.9)
        .foregroundColor(color)
      Spacer()
    }
    .padding(.horizontal, 18)
    .padding(.top, 6)
    .padding(.bottom, 6)
  }
}

// Slim dark slider
private struct DarkSlider: View {
  let label: String
  @Binding var value: Double
  let range: ClosedRange<Double>
  let accent: Color
  
  var body: some View {
    HStack(spacing: 10) {
      Text(label)
        .font(.system(size: 12))
        .foregroundColor(Color.white.opacity(0.65))
        .frame(width: 64, alignment: .leading)
      
      Slider(value: $value, in: range, step: 4)
        .tint(accent)
      
      Text("\(Int(value))px")
        .font(.system(size: 12).monospacedDigit())
        .foregroundColor(Color.white.opacity(0.65))
        .frame(width: 40, alignment: .trailing)
    }
  }
}

// Hex color helper
extension Color {
  init(hex: String) {
    let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var n: UInt64 = 0
    Scanner(string: h).scanHexInt64(&n)
    self.init(
      red:   Double((n >> 16) & 0xFF) / 255,
      green: Double((n >> 8)  & 0xFF) / 255,
      blue:  Double(n & 0xFF)         / 255
    )
  }
}
