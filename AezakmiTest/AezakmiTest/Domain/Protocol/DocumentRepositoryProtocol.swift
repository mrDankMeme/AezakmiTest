//
//  DocumentRepositoryProtocol.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation
import Combine
import UIKit

public protocol DocumentRepositoryProtocol {
    //чтение
    func list() -> AnyPublisher<[Document],Never>
    
    //создание/импорт
    func createFromImages(_ images: [UIImage], name: String?) throws -> Document
    func importFile(_ url: URL) throws -> Document
    
    //операции
    func delete(id: UUID) throws
    func shareURL(for id: UUID) throws -> URL
    
    //пригодится позже
    func merge(_ a: UUID, _ b: UUID, name: String?) throws -> Document
    func updateThumbnailIfNeeded(for id: UUID) throws
    
}
