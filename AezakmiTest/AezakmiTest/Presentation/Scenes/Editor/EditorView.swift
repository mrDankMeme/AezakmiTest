//
//  EditorView.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI

struct EditorView: View {
    @Environment(\.documentRepository) private var repo
    @StateObject private var vm: EditorViewModel = .init(repo: CompositionRoot.shared.documentRepository)
    var body: some View {
        VStack(spacing: 12) {
            Text("Здесь будет импорт фото/файлов и конвертация в PDF.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            NavigationLink("Открыть читалку (заглушка)") {
                ReaderView()
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .navigationTitle("Editor")
        
    }
}
