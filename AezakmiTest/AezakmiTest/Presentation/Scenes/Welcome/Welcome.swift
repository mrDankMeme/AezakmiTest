//
//  Welcome.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.documentRepository) private var repo
    @Environment(\.pdfService) private var pdf
    var body: some View {
        VStack(spacing: 16) {
            Text("PDF Maker")
                .font(.largeTitle).bold()
            Text("Импортируй фото/файлы → конвертируй в PDF → читай, удаляй страницы, делись.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            NavigationLink("Перейти в Editor") {
                EditorView(vm: EditorViewModel(repo: repo))
            }
            .buttonStyle(.borderedProminent)
            NavigationLink("Перейти в Library") {
                LibraryView(vm: LibraryViewModel(repo: repo))
            }
        }
        
        
    }
}



