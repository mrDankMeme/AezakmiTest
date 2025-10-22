//
//  ReaderView.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI

struct ReaderView: View {
    @Environment(\.documentRepository) private var repo
    @Environment(\.pdfService) private var pdf
    
    @StateObject var vm: ReaderViewModel
    
    init(document: Document) {
        _vm = StateObject(wrappedValue: ReaderViewModel(
            document: document,
            repo: CompositionRoot.shared.documentRepository,
            pdf: CompositionRoot.shared.pdf))
    }
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Здесь будет и PDFKitView + удаление страницы, шаринг.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .navigationTitle("Reader")
        }
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        
    }
}


