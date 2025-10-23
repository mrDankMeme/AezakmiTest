//
//  PDFService.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation
import UIKit
import PDFKit

public struct PDFService: PDFServiceProtocol {
    public init() {}

    // Создание нового PDF из изображений
    public func createPDF(from images: [UIImage], suggestedName: String?) throws -> URL {
        guard !images.isEmpty else {
            throw makeError("no images to render")
        }

        let fileStore = FileStore()
        let dst = try fileStore.uniquePDFURL(suggestedName: suggestedName)

        let pageRect: CGRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 @72dpi
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { ctx in
            for img in images {
                ctx.beginPage()
                let rect = aspectFitRect(imageSize: img.size, in: pageRect)
                img.draw(in: rect.integral)
            }
        }

        try data.write(to: dst, options: .atomic)
        return dst
    }

    // Импорт существующего PDF в песочницу
    public func importPDF(from url: URL) throws -> URL {
        let base = url.deletingPathExtension().lastPathComponent
        return try FileStore().copyToSandbox(fileAt: url, suggestedName: base)
    }

    // Миниатюра страницы
    public func thumbNail(for pdfUrl: URL, page: Int, size: CGSize) throws -> UIImage {
        guard let doc = PDFDocument(url: pdfUrl) else {
            throw makeError("Cannot open PDF")
        }
        guard let p = doc.page(at: page) else {
            throw makeError("Page out of range")
        }
        return p.thumbnail(of: size, for: .cropBox)
    }

    // Удаление страницы и пересохранение
    public func removePage(at index: Int, in PDFurl: URL) throws -> URL {
        guard let doc = PDFDocument(url: PDFurl) else {
            throw makeError("Cannot open PDF")
        }
        guard index >= 0, index < doc.pageCount else {
            throw makeError("Page out of range")
        }

        doc.removePage(at: index)
        let outURL = try FileStore().uniquePDFURL(
            suggestedName: PDFurl.deletingPathExtension().lastPathComponent
        )
        try write(doc: doc, to: outURL)
        return outURL
    }

    // Объединение целых документов
    public func merge(docs urls: [URL], suggestedName: String?) throws -> URL {
        let outDoc = PDFDocument()
        var insertIndex = 0

        for url in urls {
            guard let src = PDFDocument(url: url) else { continue }
            let count = src.pageCount
            guard count > 0 else { continue }

            for i in 0..<count {
                if let page = src.page(at: i) {
                    outDoc.insert(page, at: insertIndex)
                    insertIndex += 1
                }
            }
        }

        guard insertIndex > 0 else {
            throw makeError("No pages to merge")
        }

        let base = (suggestedName?.isEmpty == false)
            ? suggestedName!
            : "Merged-\(Int(Date().timeIntervalSince1970))"

        let outURL = try FileStore().uniquePDFURL(suggestedName: base)
        try write(doc: outDoc, to: outURL)
        return outURL
    }

    // Подсчёт страниц
    public func pageCount(of pdfURL: URL) -> Int {
        PDFDocument(url: pdfURL)?.pageCount ?? 0
    }

    // Поворот страницы
    public func rotatePage(at index: Int, in pdfURL: URL, clockwise: Bool) throws -> URL {
        guard let doc = PDFDocument(url: pdfURL) else {
            throw makeError("Не могу открыть PDF файл.")
        }
        guard let page = doc.page(at: index) else {
            throw makeError("Индекс вне диапазона.")
        }

        let current = page.rotation
        let delta = clockwise ? 90 : -90
        var newRotation = (current + delta) % 360
        if newRotation < 0 { newRotation += 360 }
        page.rotation = newRotation

        let outURL = try FileStore().uniquePDFURL(
            suggestedName: pdfURL.deletingPathExtension().lastPathComponent
        )
        try write(doc: doc, to: outURL)
        return outURL
    }

    // Добавление новой текстовой страницы
    public func appendTextPage(text: String, in pdfURL: URL) throws -> URL {
        guard let doc = PDFDocument(url: pdfURL) else {
            throw makeError("Не могу открыть PDF файл.")
        }

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        UIGraphicsBeginImageContextWithOptions(pageRect.size, true, 1)
        defer { UIGraphicsEndImageContext() }

        UIColor.white.setFill()
        UIRectFill(pageRect)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineBreakMode = .byWordWrapping

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraph
        ]

        let insetRect = pageRect.insetBy(dx: 32, dy: 32)
        (text as NSString).draw(in: insetRect, withAttributes: attrs)

        guard let img = UIGraphicsGetImageFromCurrentImageContext(),
              let page = PDFPage(image: img)
        else { throw makeError("Failed to render text page") }

        doc.insert(page, at: doc.pageCount)

        let base = pdfURL.deletingPathExtension().lastPathComponent
        let outURL = try FileStore().uniquePDFURL(suggestedName: base)
        try write(doc: doc, to: outURL)
        return outURL
    }

    // MARK: - Объединение отдельных страниц из разных документов
    public func mergePages(_ pagesByDoc: [URL: [Int]], suggestedName: String?) throws -> URL {
        let outDoc = PDFDocument()
        var insertIndex = 0

        for (url, pageIndexes) in pagesByDoc {
            guard let srcDoc = PDFDocument(url: url) else { continue }
            for index in pageIndexes {
                if let page = srcDoc.page(at: index) {
                    outDoc.insert(page, at: insertIndex)
                    insertIndex += 1
                }
            }
        }

        guard insertIndex > 0 else {
            throw makeError("Нет выбранных страниц для объединения")
        }

        let base = (suggestedName?.isEmpty == false)
            ? suggestedName!
            : "MergedPages-\(Int(Date().timeIntervalSince1970))"

        let outURL = try FileStore().uniquePDFURL(suggestedName: base)
        try write(doc: outDoc, to: outURL)
        return outURL
    }
}

// MARK: - Helpers
private extension PDFService {
    func write(doc: PDFDocument, to url: URL) throws {
        guard doc.write(to: url) else {
            throw makeError("Failed to write PDF")
        }
    }

    func aspectFitRect(imageSize: CGSize, in bounds: CGRect) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return bounds }
        let scale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        let w = imageSize.width * scale
        let h = imageSize.height * scale
        let x = bounds.minX + (bounds.width - w) / 2
        let y = bounds.minY + (bounds.height - h) / 2
        return CGRect(x: x, y: y, width: w, height: h)
    }

    func makeError(_ msg: String) -> NSError {
        NSError(domain: "PDFService", code: 1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
