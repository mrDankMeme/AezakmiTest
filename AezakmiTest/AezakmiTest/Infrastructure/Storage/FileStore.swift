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
        // 1) убираем "гирлянду" старых таймстемпов из конца имени
        let baseNoDates = stripTrailingTimestamps(from: baseRaw)
        // 2) санитайзим (никаких слэшей, двоеточий и т.п.)
        let cleanBase  = sanitize(baseNoDates.replacingOccurrences(of: " ", with: "_"))
        // 3) текущий безопасный timestamp
        let stamp = safeTimestamp()

        // Сначала собираем кандидата
        var fileName = "\(cleanBase)_\(stamp).pdf"
        // 4) укоротим, если слишком длинный (APFS: 255 байт на компонент пути; оставим запас)
        if fileName.utf8.count > maxFileNameBytes {
            // сколько байт можно выделить под "базу"
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

    /// Разрешаем только [A-Za-z0-9._-], остальное -> "_"
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

    /// Срезаем в конце "_YYYY-MM-DD_HH-mm-ss" и/или ISO-подобные "_YYYY-MM-DDTHH/mm/ssZ" — сразу "гирляндой".
    private func stripTrailingTimestamps(from name: String) -> String {
        // Охватываем и старые ISO-варианты с 'T' и слэшами, и новый безопасный формат
        // Примеры:
        // _2025-10-23T14/42/54Z
        // _2025-10-23T15/10/12Z
        // _2025-10-23_16-18-44
        let patterns = [
            #"(_\d{4}-\d{2}-\d{2}T\d{2}/\d{2}/\d{2}Z)+"#,        // ISO с T и / и Z
            #"(_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})+"#          // наш безопасный формат
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

    /// Обрезает строку по границе символов так, чтобы байтов в UTF-8 было не больше limit.
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

    /// Оставляем запас от 255. 240 байт на имя файла достаточно, чтобы точно не упереться в лимит.
    private var maxFileNameBytes: Int { 240 }
}
