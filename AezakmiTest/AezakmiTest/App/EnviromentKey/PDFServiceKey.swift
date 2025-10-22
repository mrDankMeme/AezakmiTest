//
//  PDFServiceKey.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI

private struct PDFServiceKey: SwiftUI.EnvironmentKey {
    static let defaultValue: PDFServiceProtocol = {
        CompositionRoot.shared.pdf
    }()
}

extension EnvironmentValues {
    var pdfService: PDFServiceProtocol {
        get {
            self[PDFServiceKey.self]
        } set {
            self[PDFServiceKey.self] = newValue
        }
    }
}
