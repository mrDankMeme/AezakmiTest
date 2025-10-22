//
//  ReaderContainer.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI

struct ReaderContainer: View {
    @Environment(\.documentRepository) private var repo
    @Environment(\.pdfService) private var pdf
    
    let document: Document
    
    var body: some View {
        ReaderView(vm: ReaderViewModel(document: document, repo: repo, pdf: pdf))
    }
}
