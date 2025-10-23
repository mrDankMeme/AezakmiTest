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
        reload()
    }

    // MARK: - Read

    func list() -> AnyPublisher<[Document], Never> {
        subject.eraseToAnyPublisher()
    }

    // MARK: - Create / Import

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
            if let url = try? resolveURL(obj.fileURL) {
                try? fileStore.removeFile(at: url)
            }
            context.delete(obj)
            try context.save()
            reload()
        }
    }

    func shareURL(for id: UUID) throws -> URL {
        let req: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id = %@", id as CVarArg)

        guard let obj = try context.fetch(req).first else {
            throw NSError(domain: "Repo", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])
        }
        return try resolveURL(obj.fileURL)
    }

    func merge(_ a: UUID, _ b: UUID, name: String?) throws -> Document {
        let urls = try [a, b].map { try shareURL(for: $0) }
        let out = try pdf.merge(docs: urls, suggestedName: name)
        return try persist(url: out, suggestedName: name ?? "Merged")
    }

    func updateThumbnailIfNeeded(for id: UUID) throws {
        let req: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id = %@", id as CVarArg)

        guard let obj = try context.fetch(req).first else { return }
        let url = try resolveURL(obj.fileURL)

        if obj.thumbnail == nil {
            let img = try pdf.thumbNail(for: url, page: 0, size: CGSize(width: 160, height: 200))
            obj.thumbnail = img.pngData()
            try context.save()
            reload()
        }
    }

    func replaceStoredFile(for id: UUID, with newURL: URL) throws {
        let req: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id = %@", id as CVarArg)

        guard let obj = try context.fetch(req).first else {
            throw NSError(domain: "Repo", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])
        }

        // старый файл (удалим после успешного сохранения)
        let oldResolvedURL = try? resolveURL(obj.fileURL)

        // новые метаданные
        obj.fileURL = newURL.lastPathComponent                  // <- храним только имя файла
        obj.pageCount = Int16(pdf.pageCount(of: newURL))
        if let thumb = try? pdf.thumbNail(for: newURL, page: 0, size: CGSize(width: 160, height: 200)) {
            obj.thumbnail = thumb.pngData()
        }

        try context.save()
        reload()

        // подчищаем старый физический файл
        if let old = oldResolvedURL, old != newURL {
            try? fileStore.removeFile(at: old)
        }
    }
}

// MARK: - Helpers
private extension DocumentRepositoryImpl {

    /// Собираем актуальный URL в текущем контейнере Documents из того,
    /// что лежит в БД (имя файла или наследованный полный путь/URL).
    func resolveURL(_ stored: String) throws -> URL {
        let decoded = stored.removingPercentEncoding ?? stored
        let fileName: String

        if decoded.contains("/Documents/") {
            // старый абсолютный путь (с UUID контейнера) -> берём только имя файла
            fileName = (decoded as NSString).lastPathComponent
        } else if decoded.hasPrefix("file://") {
            // старый file:// URL -> вытащим имя
            fileName = (URL(string: decoded)?.lastPathComponent) ?? (decoded as NSString).lastPathComponent
        } else {
            // уже имя файла
            fileName = decoded
        }

        let docs = try fileStore.documentsDir()
        return docs.appendingPathComponent(fileName)
    }

    /// Сохраняем метаданные документа в Core Data и отдаём модель
    @discardableResult
    func persist(url: URL, suggestedName: String) throws -> Document {
        let e = DocumentEntity(context: context)
        e.id = UUID()
        e.name = suggestedName
        e.fileURL = url.lastPathComponent          // <- храним только имя файла
        e.createdAt = Date()
        e.pageCount = Int16(pdf.pageCount(of: url))
        if let thumb = try? pdf.thumbNail(for: url, page: 0, size: CGSize(width: 160, height: 200)) {
            e.thumbnail = thumb.pngData()
        }
        try context.save()
        reload()
        return map(e)
    }

    /// Перечитываем список + выполняем мягкую миграцию старых записей
    func reload() {
        let req: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let objects = (try? context.fetch(req)) ?? []

        // Миграция: абсолютные пути/URL -> только имя файла
        var changed = false
        for o in objects {
            let s = o.fileURL
            if s.contains("/Documents/") || s.hasPrefix("file://") {
                let raw = s.removingPercentEncoding ?? s
                let fileName = URL(string: raw)?.lastPathComponent ?? (raw as NSString).lastPathComponent
                if o.fileURL != fileName {
                    o.fileURL = fileName
                    changed = true
                }
            }
        }
        if changed { try? context.save() }

        subject.send(objects.map(map))
    }

    func map(_ e: DocumentEntity) -> Document {
        let url = (try? resolveURL(e.fileURL)) ?? URL(fileURLWithPath: "/dev/null")
        let img = e.thumbnail.flatMap(UIImage.init(data:))
        return Document(
            id: e.id,
            name: e.name,
            fileURL: url,
            createdAt: e.createdAt,
            pageCount: Int(e.pageCount),
            thumbNail: img
        )
    }
}
