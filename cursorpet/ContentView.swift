//
//  ContentView.swift
//  cursorpet
//
//  Created by NS on 6/4/26.
//

import SwiftUI

struct ContentView: View {
  
  @State private var dotPosition = CGSize.zero
  
  var body: some View {
    ZStack {
      Color.blue.opacity(0.1)
        .ignoresSafeArea()
      
      Circle()
        .fill(Color.red)
        .frame(width: 30, height: 30)
        .offset(dotPosition)
    }
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { value in
          self.dotPosition = value.translation
        }
    )
  }
}

#Preview {
  ContentView()
}
