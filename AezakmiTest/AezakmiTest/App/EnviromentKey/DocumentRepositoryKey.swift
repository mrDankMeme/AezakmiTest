//
//  DocumentRepositoryKey.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI

private struct DocumentRepositoryKey: SwiftUI.EnvironmentKey {
    static let defaultValue: DocumentRepositoryProtocol = {
        CompositionRoot.shared.documentRepository
    }()
    
}

extension EnvironmentValues {
    var documentRepository: DocumentRepositoryProtocol {
        get {
            self[DocumentRepositoryKey.self]
        } set {
            self[DocumentRepositoryKey.self] = newValue
        }
    }
}
