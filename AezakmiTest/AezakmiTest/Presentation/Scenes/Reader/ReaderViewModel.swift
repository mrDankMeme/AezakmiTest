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
        document.pageCount > 1
    }
    
    func deletePage(at index: Int) {
        guard index >= 0, index < document.pageCount else {
            errorMessage = "Страница \(index + 1) вне диапазона (1–\(document.pageCount))"
            return
        }
        if document.pageCount <= 1 {
            errorMessage = "Нельзя удалить последнюю страницу"
            return
        }
        
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let newURL = try self.pdf.removePage(at: index, in: self.document.fileURL)
                try self.repo.replaceStoredFile(for: self.document.id, with: newURL)
                let newCount = self.pdf.pageCount(of: newURL)
                
                DispatchQueue.main.async {
                    self.document.fileURL = newURL
                    self.document.pageCount = newCount
                    self.currentPageIndex = min(self.currentPageIndex, max(0, newCount - 1))
                    self.isBusy = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isBusy = false
                }
            }
        }
    }
    
    func deleteCurrentPage() {
        deletePage(at: currentPageIndex)
    }
    
    func rotateCurrentPage(clockwise: Bool = true) {
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let newURL = try self.pdf.rotatePage(at: self.currentPageIndex, in: self.document.fileURL, clockwise: true)
                try self.repo.replaceStoredFile(for: self.document.id, with: newURL)
                let newCount = self.pdf.pageCount(of: newURL)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.document.fileURL = newURL
                    self.document.pageCount = newCount
                    self.isBusy = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.errorMessage = nil
                    self.isBusy = false
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
                let newURL = try self.pdf.appendTextPage(text: text, in: self.document.fileURL)
                try self.repo.replaceStoredFile(for: self.document.id, with: newURL)
                let newCount = self.pdf.pageCount(of: newURL)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.document.fileURL = newURL
                    self.document.pageCount = newCount
                    self.currentPageIndex = max(0, newCount - 1)
                    self.isBusy = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.errorMessage = error.localizedDescription
                    self.isBusy = false
                }
            }
        }
    }
    
    func shareURL() -> URL? {
        try? repo.shareURL(for: document.id)
    }

    func createDocumentFromPages(_ pages: [Int], completion: @escaping (String) -> Void) {
        guard !pages.isEmpty else { return }
        isBusy = true
        let name = "\(document.name)_SelectedPages"
        let map: [URL: [Int]] = [document.fileURL: pages.sorted()]
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            defer { DispatchQueue.main.async { self.isBusy = false } }
            do {
                _ = try self.repo.mergePages(map, name: name)
                DispatchQueue.main.async {
                    completion(name)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
