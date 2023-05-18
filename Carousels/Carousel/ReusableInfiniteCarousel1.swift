//
// ReusableInfiniteCarousel1.swift
// Carousels
//
// Created by Nicolas Nshuti on 08/05/2023
//


import SwiftUI

protocol CustomIdentifiable: Equatable {
    var customId: String { get set }
}

extension CustomIdentifiable where Self: Identifiable {
    var id: String { customId }
}

extension CustomIdentifiable where Self: AnyObject {
    var customId: ObjectIdentifier { ObjectIdentifier(self) }
}

extension CustomIdentifiable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.customId == rhs.customId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(customId)
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CustomPage: CustomIdentifiable {
    var customId: String = UUID().uuidString
    let color: Color
}

struct ReusableInfiniteCarousel1<CardView:View, T:CustomIdentifiable> : View {
    let card: (T) -> CardView
    var pages: [T] = []
    let showPageControls: Bool
    let pageControlOffset: CGFloat
    @State private var infinitePages: [T] = []
    @State private var currentPage: String = ""
    @State private var offset: CGFloat = .zero
    
    init(pages: [T], showPageControls: Bool = false, pageControlOffset: CGFloat = .zero, card: @escaping (T) -> CardView) {
        self.pages = pages
        self.card = card
        self.showPageControls = showPageControls
        self.pageControlOffset = pageControlOffset
    }
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(infinitePages, id: \.customId) { page in
                card(page)
                    .tag(page.customId)
                    .overlay {
                        GeometryReader {
                            let minX = $0.frame(in: .global).minX
                            Color.clear
                                .preference(key: OffsetPreferenceKey.self, value: minX)
                        }
                    }
            }
        }
        .onPreferenceChange(OffsetPreferenceKey.self) { offset in
            self.offset = offset
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .overlay(alignment: .bottom) {
            if showPageControls, let currentPage = currentPage {
                PageControls(currentPage: getCurrentPageIndex(with: currentPage), totalPages: pages.count)
                    .offset(y: pageControlOffset)
            }
        }
        .onChange(of: offset) { _ in
            guard offset == 0 else { return }
            let currentPageIndex = getCurrentInfinitePageIndex(with: currentPage)
            if currentPageIndex == 0 {
                let newPage = infinitePages[infinitePages.count - 2]
                currentPage = newPage.customId
            }
            if currentPageIndex == infinitePages.count - 1 {
                let newPage = infinitePages[1]
                currentPage = newPage.customId
            }
            
        }
        .onAppear {
            infinitePages.append(contentsOf: pages)
            
            currentPage = pages[0].customId
            guard var firstPage = pages.first, var lastPage = pages.last else { return }
            firstPage.customId = UUID().uuidString
            lastPage.customId = UUID().uuidString

            infinitePages.append(firstPage)
            infinitePages.insert(lastPage, at: 0)
        }
    }
    
    private func getCurrentInfinitePageIndex(with id: String) -> Int {
        infinitePages.firstIndex { $0.customId == id } ?? 0
    }
    
    private func getCurrentPageIndex(with id: String) -> Int {
        return pages.firstIndex { $0.customId == id } ?? 0
    }
}

struct InfiniteCarousel_Previews: PreviewProvider {
    static let pages: [CustomPage] = [.init(color: .red), .init(color: .yellow), .init(color: .blue), .init(color: .black), .init(color: .brown)]
    static var previews: some View {
        ReusableInfiniteCarousel1(pages: pages, showPageControls: true, pageControlOffset: -20) { page in
            RoundedRectangle(cornerRadius: 25)
                .fill(page.color)
        }
        .previewDisplayName("Reusable")
    }
}
