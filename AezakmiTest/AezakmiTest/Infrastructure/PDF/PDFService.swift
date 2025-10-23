//
//  PDFService.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation
import UIKit
import PDFKit

public struct PDFService : PDFServiceProtocol {
    public init() {
        
    }
    
    public func createPDF(from images: [UIImage], suggestedName: String?) throws -> URL {
        
        guard !images.isEmpty else {
            throw makeError("no images to render")
        }
        
        let fileStore = FileStore()
        let dst = try fileStore.uniquePDFURL(suggestedName: suggestedName)
        
        // A4 @72dpi
        let pageRect : CGRect = CGRect(x: 0, y: 0, width: 595, height: 842)
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
    
    // Копируем существующий PDF в песочницу (Documents/)
    public func importPDF(from url: URL) throws -> URL {
        let base = url.deletingPathExtension().lastPathComponent
        return try FileStore().copyToSandbox(fileAt: url, suggestedName: base)
    }

    
    // Миниатюра первой (или заданной) страницы
    public func thumbNail(for pdfUrl: URL, page: Int, size: CGSize) throws -> UIImage {
        guard let doc = PDFDocument(url: pdfUrl) else {
            throw makeError("Cannot open PDF")
        }
        guard let p = doc.page(at: page) else {
            throw makeError("Page out of range")
        }
        
        return p.thumbnail(of: size, for: .cropBox)
    }
    
    //Удаление страницы и пересохранение в новый файл
    public func removePage(at index: Int, in PDFurl: URL) throws -> URL {
        guard let doc = PDFDocument(url: PDFurl) else {
            throw makeError("Cannot open PDF")
        }
        guard index>=0, index<doc.pageCount else {
            throw makeError("Page out of range")
        }
        
        doc.removePage(at: index)
        
        let outURL = try FileStore().uniquePDFURL(suggestedName: PDFurl.deletingPathExtension().lastPathComponent   )
        try write(doc: doc, to: outURL)
        return outURL
    }
    
    //Обьединение нескольких PDF в один (пока только зачаток)
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

    public func pageCount(of pdfURL: URL) -> Int {
        return PDFDocument(url: pdfURL)?.pageCount ?? 0
    }
    
    // Поворачиваем странчку на 90 градусов
    public func rotatePage(at index: Int, in pdfURL: URL, clockwise: Bool) throws -> URL {
        guard let doc = PDFDocument(url: pdfURL) else {
            throw makeError("Не могу открыть PDF файл.")
        }
        guard let page = doc.page(at: index) else {
            throw makeError("Индекс аут от рендж.")
        }
        
        let current = page.rotation
        let delta = clockwise ? 90 : -90
        var newRotation = (current + delta) % 360
        if newRotation < 0 { newRotation += 360 }
        page.rotation = newRotation
        
        let outURL = try FileStore().uniquePDFURL(suggestedName: pdfURL.deletingPathExtension().lastPathComponent)
        try write(doc: doc, to: outURL)
        return outURL
    }
    
    public func appendTextPage(text: String, in pdfURL: URL) throws -> URL {
        guard let doc = PDFDocument(url: pdfURL) else {
            throw makeError("Не могу открыть PDF файл.")
        }
        // Рисуем
        let pageRect = CGRect(x: 0, y: 0, width: 595.0, height: 842.0)
        UIGraphicsBeginImageContextWithOptions(pageRect.size, true, 1)
        defer { UIGraphicsEndImageContext() }
        // Фон
        UIColor.white.setFill()
        UIRectFill(pageRect)
        
        // атрибуты текста
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineBreakMode = .byWordWrapping
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraph
        ]
        
        // поля страницы
        let insetRect = pageRect.insetBy(dx: 32, dy: 32)
        let ns = text as NSString
        
        // многострочный вывод в прямоугольник
        ns.draw(in: insetRect,withAttributes: attrs)
        
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            throw makeError("Failed to render text page")
        }
        
        //Создаем PDFPage из изображения и добавляем в документ
        guard let page = PDFPage(image: img) else {
            throw makeError("Failed to create PDFPage from image")
        }
        doc.insert(page, at: doc.pageCount)
        
        //сохраняем в новый файл
        let base = pdfURL.deletingPathExtension().lastPathComponent
        let outURL = try FileStore().uniquePDFURL(suggestedName: base)
        try write(doc: doc, to: outURL)
        return outURL
    }
}

//MARK: - Helpers
private extension PDFService {
    private func write(doc: PDFDocument, to url: URL) throws {
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
