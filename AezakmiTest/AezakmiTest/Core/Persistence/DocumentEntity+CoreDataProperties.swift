//
//  DocumentEntity+CoreDataProperties.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//


import Foundation
import CoreData

extension DocumentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentEntity> {
        return NSFetchRequest<DocumentEntity>(entityName: "DocumentEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var fileURL: String
    @NSManaged public var createdAt: Date
    @NSManaged public var pageCount: Int16
    @NSManaged public var thumbnail: Data?
}

extension DocumentEntity : Identifiable {}
