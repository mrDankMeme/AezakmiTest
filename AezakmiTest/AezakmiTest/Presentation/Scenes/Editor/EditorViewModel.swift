//
//  EditorViewModel.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import UIKit
import Combine

final class EditorViewModel: ObservableObject {
    @Published var pickedImages: [UIImage] = []
    @Published var importedFileURL: URL?
    @Published var createdDocument: Document?
    
    @Published var isBusy: Bool = false
    @Published var errorMessage: String?
    
    private let repo: DocumentRepositoryProtocol
 
    init(repo: DocumentRepositoryProtocol) {
        self.repo = repo
    }
    func createPDF(name: String?) {
        guard !pickedImages.isEmpty || importedFileURL != nil else { return }
        isBusy = true
        
        let title = (name?.isEmpty == false) ? name : nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let doc: Document
                
                if !self.pickedImages.isEmpty {
                    doc = try repo.createFromImages(pickedImages, name: name)
                } else if let url = self.importedFileURL {
                    doc = try repo.importFile(url)
                } else {
                    throw NSError(domain: "EditorVM", code: 0, userInfo: [NSLocalizedDescriptionKey:"No data"])
                }
                
                DispatchQueue.main.async {
                    self.createdDocument = doc
                    self.isBusy = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isBusy = false
                }
            }
        }
        
        func reset() {
            pickedImages = []
            importedFileURL = nil
            createdDocument = nil
        }
    }
}
