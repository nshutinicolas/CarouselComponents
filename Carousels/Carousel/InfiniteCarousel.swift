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
}

extension CustomIdentifiable where Self: Identifiable {
    var id: ID { customId }
}

extension CustomIdentifiable where Self: AnyObject, ID == ObjectIdentifier {
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

struct Page: Identifiable, Hashable {
    var id: UUID = .init()
    let color: Color
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

struct InfiniteCarousel: View {
    @State private var currentPage: String = ""
    @State var pagePadding: CGFloat = 100
    @State private var pages: [Page] = []
    @State private var infinitePages: [Page] = []
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                TabView(selection: $currentPage) {
                    ForEach(infinitePages) { page in
                        RoundedRectangle(cornerRadius: 25)
                            .fill(page.color.gradient)
                            .tag(page.id.uuidString)
                            .frame(width: size.width - 100, height: size.height)
                            .offsetX(currentPage == page.id.uuidString) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(getInfinitePageIndex(for: page)))
                                let progress = pageOffset / size.width
                                
                                if -progress < 1.0 {
                                    guard let lastPage = infinitePages.last else { return }
                                    currentPage = lastPage.id.uuidString
                                }
                                
                                if -progress > CGFloat(infinitePages.count - 1) {
                                    guard infinitePages.indices.contains(1) else { return }
                                    currentPage = infinitePages[1].id.uuidString
                                }
                            }
                    }
                }
                .navigationTitle("Infinite Carousel")
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(alignment: .bottom) {
                    PageControls(currentPage: getCurrentPageIndex(for: currentPage), totalPages: pages.count)
                        .offset(y: -20)
                }
                .onChange(of: currentPage) { index in
                    /// This works but not the best
//                    if index == infinitePages.last?.id.uuidString {
//                        currentPage = pages[0].id.uuidString
//                    }
//                    if index == infinitePages.first?.id.uuidString {
//                        currentPage = pages[pages.count - 1].id.uuidString
//                    }
                }
            }
        }
        .onAppear {
            let mockPages: [Page] = [.init(color: .red), .init(color: .brown),
                                     .init(color: .yellow), .init(color: .green),
                                     .init(color: .blue)]
            pages.append(contentsOf: mockPages)
            infinitePages.append(contentsOf: pages)
            
            // Work on appending First and last pages to infinite pages
            if var firstPage = infinitePages.first, var lastPage = infinitePages.last {
                // Update the current page
                currentPage = firstPage.id.uuidString
                
                // Modify UUID for first and last pages
                firstPage.id = .init()
                lastPage.id = .init()
                // Append The first page to make it the last
                infinitePages.append(firstPage)
                // Insert last page to make it the first
                infinitePages.insert(lastPage, at: 0)
            }
        }
    }
    
    func getInfinitePageIndex(for page: Page) -> Int {
        return infinitePages.firstIndex(of: page) ?? 0
    }
    
    func getCurrentPageIndex(for id: String) -> Int {
        return pages.firstIndex { $0.id.uuidString == id } ?? 0
    }
}

struct CustomPage: CustomIdentifiable {
    var customId: UUID = .init()
    let color: Color
}

struct ReusableInfiniteCarousel<CardView:View, T:CustomIdentifiable> : View {
    let card: (T) -> CardView
    var pages: [T] = []
    let showPageControls: Bool
    let pageControlOffset: CGFloat
    @State private var infinitePages: [T] = []
    @State var currentPage: T.ID?
    
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
                            .tag(page.customId)
                            .offsetX(currentPage == page.customId) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(getInfinitePageIndex(for: page)))
                                let progress = pageOffset / size.width
                                
                                if -progress < 1.0 {
                                    guard let lastPage = infinitePages.last else { return }
                                    currentPage = lastPage.customId
                                }
                                
                                if -progress > CGFloat(infinitePages.count - 1) {
                                    guard infinitePages.indices.contains(1) else { return }
                                    currentPage = infinitePages[1].customId
                                }
                            }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(alignment: .bottom) {
                    if showPageControls, let currentPage {
                        PageControls(currentPage: getPageIndex(with: currentPage), totalPages: pages.count)
                            .offset(y: pageControlOffset)
                    }
                }
            }
        }
        .onAppear {
            infinitePages.append(contentsOf: pages)
            
            currentPage = pages[0].customId
            guard var firstPage = pages.first, var lastPage = pages.last else { return }
            guard let firstPageId = UUID() as? T.ID, let lastPageId = UUID() as? T.ID else { return }
            firstPage.customId = firstPageId
            lastPage.customId = lastPageId
            
            infinitePages.append(firstPage)
            infinitePages.insert(lastPage, at: 0)
        }
    }
    
    func getInfinitePageIndex(for page: T) -> Int {
        infinitePages.firstIndex(of: page) ?? 0
    }
    
    func getPageIndex(with id: T.ID) -> Int {
        pages.firstIndex { $0.customId == id } ?? 0
    }
}


struct InfiniteCarousel_Previews: PreviewProvider {
    static let pages: [CustomPage] = [.init(color: .red), .init(color: .yellow)]
    static var previews: some View {
        ReusableInfiniteCarousel(pages: pages, showPageControls: true, pageControlOffset: -20) { page in
            RoundedRectangle(cornerRadius: 25)
                .fill(page.color.gradient)
        }
//        InfiniteCarousel()
    }
}
