//
//  FileStore.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import Foundation

public class FileStore: FileStoreProtocol {

    public init() {}

    public func documentsDir() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true)
    }

    // MARK: - Public

    public func uniquePDFURL(suggestedName: String?) throws -> URL {
        let baseRaw = (suggestedName?.isEmpty == false ? suggestedName! : "Document")
        
        let baseNoDates = stripTrailingTimestamps(from: baseRaw)
        
        let cleanBase  = sanitize(baseNoDates.replacingOccurrences(of: " ", with: "_"))
        
        let stamp = safeTimestamp()

        
        var fileName = "\(cleanBase)_\(stamp).pdf"
        
        if fileName.utf8.count > maxFileNameBytes {
            
            let reserved = ("_\(stamp).pdf").utf8.count
            let allowedForBase = max(1, maxFileNameBytes - reserved)
            let trimmedBase = trimToUTF8Limit(cleanBase, limit: allowedForBase)
            fileName = "\(trimmedBase)_\(stamp).pdf"
        }

        return try documentsDir().appendingPathComponent(fileName, isDirectory: false)
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

    // MARK: - Internals

    /// Безопасный timestamp без двоеточий/слэшей.
    private func safeTimestamp() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return df.string(from: Date())
    }

    
    private func sanitize(_ s: String) -> String {
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
        var out = ""
        out.reserveCapacity(s.count)
        for u in s.unicodeScalars {
            out.append(allowed.contains(u) ? Character(u) : "_")
        }
        // не допускаем пустого имени
        return out.isEmpty ? "Document" : out
    }

    
    private func stripTrailingTimestamps(from name: String) -> String {
        
        let patterns = [
            #"(_\d{4}-\d{2}-\d{2}T\d{2}/\d{2}/\d{2}Z)+"#,
            #"(_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})+"#
        ]

        var result = name
        for p in patterns {
            if let re = try? NSRegularExpression(pattern: p + "$", options: []) {
                result = re.stringByReplacingMatches(in: result,
                                                     options: [],
                                                     range: NSRange(location: 0, length: (result as NSString).length),
                                                     withTemplate: "")
            }
        }
        return result
    }

    
    private func trimToUTF8Limit(_ s: String, limit: Int) -> String {
        guard s.utf8.count > limit else { return s }
        var bytes = 0
        var out = ""
        out.reserveCapacity(min(s.count, limit))
        for ch in s {
            let len = String(ch).utf8.count
            if bytes + len > limit { break }
            out.append(ch)
            bytes += len
        }
        return out.isEmpty ? "D" : out
    }

     
    private var maxFileNameBytes: Int { 240 }
}
