import SwiftUI
import AppKit
import UniformTypeIdentifiers

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
        // ← Используем allCases, чтобы screenshot всегда был виден
        ForEach(BuddyState.allCases, id: \.self) { state in
          StateRow(state: state, stateManager: stateManager)
        }
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 4)
      
      // Предупреждение о Accessibility — показываем если screenshot заблокирован
      if !ScreenshotKeyMonitor.isAccessibilityEnabled {
        accessibilityWarning
      }
      
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
  
  // MARK: - Accessibility Warning
  
  private var accessibilityWarning: some View {
    HStack(spacing: 8) {
      Image(systemName: "lock.shield.fill")
        .font(.system(size: 12))
        .foregroundColor(Color(hex: "#FFB800"))
      
      VStack(alignment: .leading, spacing: 2) {
        Text("Screenshot reaction disabled")
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(Color.white.opacity(0.75))
        Text("Enable Accessibility to unlock")
          .font(.system(size: 11))
          .foregroundColor(Color.white.opacity(0.45))
      }
      
      Spacer()
      
      Button(action: openAccessibilitySettings) {
        HStack(spacing: 4) {
          Text("Open Settings")
            .font(.system(size: 11, weight: .medium))
          Image(systemName: "arrow.up.right.square")
            .font(.system(size: 10))
        }
        .foregroundColor(accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
          RoundedRectangle(cornerRadius: 6)
            .fill(accent.opacity(0.12))
            .overlay(
              RoundedRectangle(cornerRadius: 6)
                .strokeBorder(accent.opacity(0.30), lineWidth: 0.5)
            )
        )
      }
      .buttonStyle(.plain)
      .cursor(.pointingHand)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(hex: "#FFB800").opacity(0.06))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color(hex: "#FFB800").opacity(0.20), lineWidth: 0.5)
        )
    )
    .padding(.horizontal, 12)
    .padding(.top, 4)
    .padding(.bottom, 2)
  }
  
  private func openAccessibilitySettings() {
    guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
      return
    }
    NSWorkspace.shared.open(url)
  }
}

// MARK: - Section Label

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

// MARK: - Dark Slider

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

// MARK: - Cursor Modifier

private struct CursorModifier: ViewModifier {
  let cursor: NSCursor
  
  func body(content: Content) -> some View {
    content
      .onHover { isHovered in
        isHovered ? cursor.push() : cursor.pop()
      }
  }
}

extension View {
  func cursor(_ cursor: NSCursor) -> some View {
    modifier(CursorModifier(cursor: cursor))
  }
}

// MARK: - Hex Color Helper

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
