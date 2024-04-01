//
//  ContentView.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-03-31.
//

import SwiftUI

struct ContentView: View {
    @State var value: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                RollingText(font: .system(size: 55), weight: .black, value: $value)

                Button("Change Value") {
                    value = .random(in: 100...1300)
                }
            }
            .padding()
            .navigationTitle("Rolling text")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
