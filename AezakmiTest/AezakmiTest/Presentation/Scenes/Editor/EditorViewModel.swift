//
//  EditorViewModel.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import UIKit
import Combine
import UniformTypeIdentifiers

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
                    doc = try self.repo.createFromImages(self.pickedImages, name: title)
                } else if let url = self.importedFileURL {
                    let secured = url.startAccessingSecurityScopedResource()
                    defer { if secured { url.stopAccessingSecurityScopedResource() } }

                    let contentType = (try? url.resourceValues(forKeys: [.contentTypeKey]).contentType)

                    if contentType == .pdf || url.pathExtension.lowercased() == "pdf" {
                        doc = try self.repo.importFile(url)
                    } else if contentType?.conforms(to: .image) == true {
                        guard let img = FileImageLoader.loadFirstImage(from: url) else {
                            throw NSError(domain: "EditorVM", code: -2, userInfo: [NSLocalizedDescriptionKey: "Не удалось прочитать изображение"])
                        }
                        doc = try self.repo.createFromImages([img], name: title)
                    } else {
                        throw NSError(domain: "EditorVM", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неподдерживаемый тип файла"])
                    }
                } else {
                    throw NSError(domain: "EditorVM", code: 0, userInfo: [NSLocalizedDescriptionKey: "Нет данных для импорта"])
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
    }
}
