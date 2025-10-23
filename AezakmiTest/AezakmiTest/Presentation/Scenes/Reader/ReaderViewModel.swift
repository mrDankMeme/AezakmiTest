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
    
    func canDeleteCurrentPage() -> Bool {
        document.pageCount > 1 // не даю ему удалить последнюю старницу, потому что не хочу получить пустой документ
    }
  
    func deleteCurrentPage() {
        guard canDeleteCurrentPage() else { return }
        do {
            let newURL = try pdf.removePage(at: currentPageIndex, in: document.fileURL)
            
            try repo.replaceStoredFile(for: document.id, with: newURL)
            
            
            document.fileURL = newURL
            document.pageCount = pdf.pageCount(of: newURL)
            if currentPageIndex >= document.pageCount {
                currentPageIndex = max(0, document.pageCount - 1)
            }
        } catch {
            print("Delete page error: \(error)")
        }
    }
    
    func rotateCurrentPage(clockwise: Bool = true) {
        do {
            let newURL = try pdf.rotatePage(at: currentPageIndex, in: document.fileURL, clockwise: true)
            try repo.replaceStoredFile(for: document.id, with: newURL)
            
            document.fileURL = newURL
            document.pageCount = pdf.pageCount(of: newURL)
        } catch {
            print("Rotate page error: \(error)")
        }
    }
    
    func shareURL() -> URL? {
        try? repo.shareURL(for: document.id)
    }
}

