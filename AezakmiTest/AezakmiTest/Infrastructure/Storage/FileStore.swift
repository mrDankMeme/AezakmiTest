//
//  FileStore.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation

public class FileStore: FileStoreProtocol {
   
    
    public init() {
        
    }
    
    public func documentsDir() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    public func uniquePDFURL(suggestedName: String?) throws -> URL {
        let base = (suggestedName?.isEmpty == false ? suggestedName! : "Document")
                   .replacingOccurrences(of: " ", with: "_")
               let stamp = ISO8601DateFormatter().string(from: Date())
               return try documentsDir().appendingPathComponent("\(base)_\(stamp).pdf")
    }
    
    public func copyToSandbox(fileAt url: URL, suggestedName: String?) throws -> URL {
        let suggested = suggestedName ?? url.deletingPathExtension().lastPathComponent
              let dst = try uniquePDFURL(suggestedName: suggested)
              try FileManager.default.copyItem(at: url, to: dst)
              return dst
    }
    
    public func removeFile(at url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
                   try FileManager.default.removeItem(at: url)
               }
    }

    
}
