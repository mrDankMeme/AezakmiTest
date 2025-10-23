//
//  PDFStoreProtocol.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation
import UIKit

public protocol PDFServiceProtocol {
    func createPDF(from images: [UIImage], suggestedName: String?) throws -> URL
    func importPDF(from url: URL) throws -> URL
    func thumbNail(for pdfUrl: URL, page: Int, size: CGSize) throws -> UIImage
    func removePage(at: Int, in PDFurl: URL) throws -> URL
    func merge(docs urls: [URL], suggestedName: String?) throws -> URL
    func pageCount(of pdfURL: URL) -> Int
    func rotatePage(at index: Int, in pdfURL: URL, clockwise: Bool) throws -> URL
}
