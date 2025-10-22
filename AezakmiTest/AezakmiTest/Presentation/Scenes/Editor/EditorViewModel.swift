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
    
    private let repo: DocumentRepositoryProtocol
 
    init(repo: DocumentRepositoryProtocol) {
        self.repo = repo
    }
    func createPDF(name: String?) {
        do {
            if !pickedImages.isEmpty {
                createdDocument = try repo.createFromImages(pickedImages, name: name)
            } else if let url = importedFileURL {
                createdDocument = try repo.importFile(url)
            }
        } catch {
            print("Create PDF error: \(error)")
        }
    }
}
