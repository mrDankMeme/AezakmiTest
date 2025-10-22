//
//  FileStoreProtocol.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation

public protocol FileStoreProtocol {
    func documentsDir() throws -> URL
    func uniquePDFURL(suggestedName: String?) throws -> URL
    func copyToSandbox(fileAt: URL, suggestedName: String?) throws -> URL
    func removeFile(at url: URL) throws
}

