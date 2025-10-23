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
    
    @Published var isBusy = false
    @Published var errorMessage: String?

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
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let newURL = try pdf.removePage(at: currentPageIndex, in: document.fileURL)
                try repo.replaceStoredFile(for: document.id, with: newURL)
                let newCount = pdf.pageCount(of: newURL)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    document.fileURL = newURL
                    document.pageCount = newCount
                    if currentPageIndex >= document.pageCount {
                        currentPageIndex = max(0, document.pageCount - 1)
                    }
                    isBusy = false
                }
            } catch {
                DispatchQueue.main.async {
                    [weak self] in
                    guard let self = self else { return }
                    isBusy = false
                    errorMessage = nil
                }
               
            }
        }
    }
    
    func rotateCurrentPage(clockwise: Bool = true) {
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let newURL = try pdf.rotatePage(at: currentPageIndex, in: document.fileURL, clockwise: true)
                try repo.replaceStoredFile(for: document.id, with: newURL)
                let newCount = pdf.pageCount(of: newURL)
          
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    document.fileURL = newURL
                    document.pageCount = newCount
                    isBusy = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    errorMessage = nil
                    isBusy = false
                }
            }
        }
     
    }
    func addTextPage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let newURL = try pdf.appendTextPage(text: text, in: document.fileURL)
                try self.repo.replaceStoredFile(for: self.document.id, with: newURL)
                let newCount = self.pdf.pageCount(of: newURL)
                
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    document.fileURL = newURL
                    document.pageCount = newCount
                    currentPageIndex = max (0, newCount - 1)
                    isBusy = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    errorMessage = error.localizedDescription
                    isBusy = false
                }
            }
        }
        
    }
    
    func shareURL() -> URL? {
        try? repo.shareURL(for: document.id)
    }
}

