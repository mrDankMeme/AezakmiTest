//
//  CompositionRoot.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import Foundation
import CoreData

@MainActor
final class CompositionRoot {
    static let shared = CompositionRoot()
    
    let coreData = CoreDataStack(modelName: "DocumentsModel")
    let fileStore : FileStoreProtocol = FileStore()
    let pdf : PDFServiceProtocol = PDFService()
    
    lazy var documentRepository: DocumentRepositoryProtocol = {
        DocumentRepositoryImpl(
            context: coreData.viewContext,
            fileStore: fileStore,
            pdf: pdf
        )
    }()
    
    private init() {}
    
}
