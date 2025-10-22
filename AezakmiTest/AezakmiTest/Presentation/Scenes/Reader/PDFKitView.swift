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
    }
  
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator:NSObject, PDFViewDelegate {
        let parent: PDFKitView
        init(_ parent: PDFKitView) {
            self.parent = parent
        }
        
        
        func pdfViewPageChanged(_ sender: PDFView) {
            if let page = sender.currentPage,
                let doc = sender.document {
                    parent.currentPageIndex = doc.index(for: page)
            }
        }
    }
}

