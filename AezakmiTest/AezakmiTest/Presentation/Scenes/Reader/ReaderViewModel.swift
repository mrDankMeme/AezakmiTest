//
//  ReaderViewModel.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import Foundation
import Combine

final class ReaderViewModel : ObservableObject {
    @Published private(set) var document: Document
    @Published var currentPageIndex: Int = 0
    
    private let repo: DocumentRepositoryProtocol
    private let pdf: PDFServiceProtocol
    
    init(document: Document,
         repo: DocumentRepositoryProtocol,
         pdf: PDFServiceProtocol) {
        self.document = document
        self.repo = repo
        self.pdf = pdf
    }
    
    func deleteCurrentPage() {
        do {
            let newURL = try pdf.removePage(at: currentPageIndex, in: document.fileURL)
            document.fileURL = newURL
            document.pageCount = pdf.pageCount(of: newURL)
            try repo.updateThumbnailIfNeeded(for: document.id)
        } catch {
            print("Delete page error: \(error)")
        }
    }
    
    func shareURL() -> URL? {
        try? repo.shareURL(for: document.id)
    }
}

