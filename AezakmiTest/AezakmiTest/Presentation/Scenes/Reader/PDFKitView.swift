//
//  PDFKitView.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL
    @Binding var currentPageIndex: Int

    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.delegate = context.coordinator
        v.document = PDFDocument(url: url)
        return v
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.documentURL != url {
            uiView.document = PDFDocument(url: url)
        }
        if let doc = uiView.document,
           currentPageIndex >= 0,
           currentPageIndex < doc.pageCount,
           let page = doc.page(at: currentPageIndex),
           uiView.currentPage != page {
            uiView.go(to: page)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PDFViewDelegate {
        let parent: PDFKitView
        init(_ parent: PDFKitView) { self.parent = parent }

        func pdfViewPageChanged(_ sender: PDFView) {
            guard let page = sender.currentPage,
                  let doc = sender.document else { return }
            parent.currentPageIndex = doc.index(for: page)
        }
    }
}
