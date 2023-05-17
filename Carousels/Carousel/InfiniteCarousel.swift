//
// InfiniteCarousel.swift
// Carousels
//
// Created by Nicolas Nshuti on 08/05/2023
//


import SwiftUI

protocol CustomIdentifiable: Equatable {
    associatedtype ID: Hashable
    var customId: ID { get set }
    var stringId: String { get set }
}

extension CustomIdentifiable where Self: Identifiable {
    var id: ID { customId }
}

extension CustomIdentifiable where Self: AnyObject, ID == ObjectIdentifier {
    var customId: ObjectIdentifier { ObjectIdentifier(self) }
}

extension CustomIdentifiable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.customId == rhs.customId && lhs.stringId == rhs.stringId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(customId)
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func offsetX(_ oberseved: Bool, completion: @escaping (CGRect) -> ()) -> some View {
        self.frame(maxWidth: .infinity)
            .overlay {
                if oberseved {
                    GeometryReader {
                        let rect = $0.frame(in: .global)
                        Color.clear
                            .preference(key: OffsetPreferenceKey.self, value: rect)
                            .onPreferenceChange(OffsetPreferenceKey.self, perform: completion)
                    }
                }
            }
    }
}

struct CustomPage: CustomIdentifiable {
    var customId: UUID = .init()
    var stringId: String = UUID().uuidString
    let color: Color
}

struct ReusableInfiniteCarousel<CardView:View, T:CustomIdentifiable> : View {
    let card: (T) -> CardView
    var pages: [T] = []
    let showPageControls: Bool
    let pageControlOffset: CGFloat
    @State private var infinitePages: [T] = []
    @State private var currentPage: String = ""
    
    init(pages: [T], showPageControls: Bool = false, pageControlOffset: CGFloat = 0, card: @escaping (T) -> CardView) {
        self.pages = pages
        self.card = card
        self.showPageControls = showPageControls
        self.pageControlOffset = pageControlOffset
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                TabView(selection: $currentPage) {
                    ForEach(infinitePages, id: \.customId) { page in
                        card(page)
                            .tag(page.stringId)
                            .offsetX(true) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(getCurrentInfinitePageIndex(for: page)))
                                let progress = pageOffset / size.width
                                
                                print("Current:", getCurrentPageIndex(with: page.stringId))
                                print("CurrentInfinite:", getCurrentInfinitePageIndex(for: page))
                                if -progress < 1.0 {
                                    guard let lastPage = infinitePages.last else { return }
                                    currentPage = lastPage.stringId
                                }
                                
                                if -progress > CGFloat(infinitePages.count - 1) {
                                    guard infinitePages.indices.contains(1) else { return }
                                    currentPage = infinitePages[1].stringId
                                }
                            }
                    }
                }
                .navigationTitle("Infinite carousel")
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(alignment: .bottom) {
                    if showPageControls, let currentPage = currentPage {
                        PageControls(currentPage: getCurrentPageIndex(with: currentPage), totalPages: pages.count)
                            .offset(y: pageControlOffset)
                    }
                }
            }
        }
        .onAppear {
            infinitePages.append(contentsOf: pages)
            
            currentPage = pages[0].stringId
            guard var firstPage = pages.first, var lastPage = pages.last else { return }
            guard let firstPageId = UUID() as? T.ID, let lastPageId = UUID() as? T.ID else { return }
            firstPage.customId = firstPageId
            firstPage.stringId = UUID().uuidString
            lastPage.customId = lastPageId
            lastPage.stringId = UUID().uuidString

            infinitePages.append(firstPage)
            infinitePages.insert(lastPage, at: 0)
        }
    }
    
    func getCurrentInfinitePageIndex(for page: T) -> Int {
        infinitePages.firstIndex(of: page) ?? 0
    }
    
    func getCurrentPageIndex(with id: String) -> Int {
        return pages.firstIndex { $0.stringId == id } ?? 0
    }
}


struct InfiniteCarousel_Previews: PreviewProvider {
    static let pages: [CustomPage] = [.init(color: .red), .init(color: .yellow), .init(color: .blue), .init(color: .black), .init(color: .brown)]
    static var previews: some View {
            ReusableInfiniteCarousel(pages: pages, showPageControls: true, pageControlOffset: -20) { page in
                RoundedRectangle(cornerRadius: 25)
                    .fill(page.color.gradient)
            }
            .previewDisplayName("Reusable")
    }
}
