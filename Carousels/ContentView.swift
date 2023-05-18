//
// ContentView.swift
// Carousels
//
// Created by Nicolas Nshuti on 08/05/2023
//


import SwiftUI

struct ContentView: View {
    let pages: [CustomPage] = [.init(color: .red), .init(color: .yellow), .init(color: .blue), .init(color: .pink), .init(color: .orange)]
    var body: some View {
        ReusableInfiniteCarousel1(pages: pages, showPageControls: true, pageControlOffset: -20) { page in
            RoundedRectangle(cornerRadius: 25)
                .fill(page.color)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
