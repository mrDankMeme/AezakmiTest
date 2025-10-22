//
//  DocumentRepositoryImpl.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation
import CoreData
import Combine
import UIKit
import PDFKit

final class DocumentRepositoryImpl: DocumentRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    private let fileStore: FileStoreProtocol
    private let pdf: PDFServiceProtocol
    
    private let subject = CurrentValueSubject<[Document], Never>([])
    init(context: NSManagedObjectContext, fileStore: FileStoreProtocol, pdf: PDFServiceProtocol) {
        self.context = context
        self.fileStore = fileStore
        self.pdf = pdf
    }
    
    func list() -> AnyPublisher<[Document], Never> {
        subject.eraseToAnyPublisher()
    }
    
    func createFromImages(_ images: [UIImage], name: String?) throws -> Document {
        let url = try pdf.createPDF(from: images, suggestedName: name)
        return try persist(url: url, suggestedName: name ?? "Document")
        
    }
    
    func importFile(_ url: URL) throws -> Document {
        let dst = try pdf.importPDF(from: url)
        return try persist(url: dst, suggestedName: url.deletingPathExtension().lastPathComponent)
    }
    
    // MARK: - Ops
    
    func delete(id: UUID) throws {
        let req: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        
        if let obj = try context.fetch(req).first {
            let s = obj.fileURL
            if let url = URL(string: s) {
                try fileStore.removeFile(at: url)
            }
            context.delete(obj)
            try context.save()
            reload()
        }
    }
    
    func shareURL(for id: UUID) throws -> URL {
        let req : NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        
        guard let obj = try context.fetch(req).first,
              let url = URL(string: obj.fileURL) else {
            throw NSError(domain: "Repo", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])
        }
        return url
    }
    
    func merge(_ a: UUID, _ b: UUID, name: String?) throws -> Document {
        let urls = try [a,b].map{
            try shareURL(for:$0)
        }
       let out = try pdf.merge(docs: urls, suggestedName: name)
        return try persist(url: out, suggestedName: name ?? "Merged")
        
        
    }
    
    func updateThumbnailIfNeeded(for id: UUID) throws {
        let req : NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        guard let obj = try context.fetch(req).first,
              let url = URL(string: obj.fileURL) else {
                 return
              }
        if obj.thumbnail == nil {
            let img = try pdf.thumbNail(for: url, page: 0, size: CGSize(width: 160 , height: 200))
            obj.thumbnail = img.pngData()
            try context.save()
            reload()
        }
    }
}

// MARK: - Helpers
private extension DocumentRepositoryImpl {
    @discardableResult
    private func persist(url: URL, suggestedName:String) throws -> Document {
        let e = DocumentEntity(context: context)
        e.id = UUID()
        e.name = suggestedName
        e.fileURL = url.absoluteString
        e.createdAt = Date()
        e.pageCount = Int16(pdf.pageCount(of: url))
        if let thumb = try? pdf.thumbNail(for: url, page: 0, size: CGSize(width: 160, height: 200)) {
            e.thumbnail = thumb.pngData()
        }
        try context.save()
        reload()
        return map(e)
    }
    private func reload() {
        let req: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let objects = (try? context.fetch(req)) ?? []
        
        subject.send(objects.map(map))
    }
    
    func map(_ e: DocumentEntity) -> Document {
        let url = URL(string: e.fileURL) ?? URL(fileURLWithPath: "/dev/null")
        let img = e.thumbnail.flatMap(UIImage.init(data:))
        return Document(id: e.id,
                        name: e.name,
                        fileURL: url,
                        createdAt: e.createdAt,
                        pageCount: Int(e.pageCount),
                        thumbNail: img)
    }
}
