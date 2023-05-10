//
// PageControls.swift
// Carousels
//
// Created by Nicolas Nshuti on 08/05/2023
//


import SwiftUI

struct PageControls: UIViewRepresentable {
    let currentPage: Int
    let totalPages: Int
    let allowInteraction: Bool = false
    
    func makeUIView(context: Context) -> UIPageControl {
        let controls = UIPageControl()
        controls.currentPage = currentPage
        controls.numberOfPages = totalPages
        controls.allowsContinuousInteraction = allowInteraction
        controls.backgroundStyle = .prominent
        
        return controls
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
}
