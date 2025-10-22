//
//  Document.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation
import UIKit

public struct Document: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var fileURL: URL
    public var createdAt: Date
    public var pageCount: Int
    public var thumbNail: UIImage?
    
    public init(id: UUID, name: String, fileURL: URL, createdAt: Date, pageCount: Int, thumbNail: UIImage? = nil) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.createdAt = createdAt
        self.pageCount = pageCount
        self.thumbNail = thumbNail
    }
    
}
