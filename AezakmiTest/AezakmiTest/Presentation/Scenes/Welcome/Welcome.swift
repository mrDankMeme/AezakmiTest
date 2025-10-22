//
//  Welcome.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("PDF Maker")
                .font(.largeTitle).bold()
            Text("Импортируй фото/файлы → конвертируй в PDF → читай, удаляй страницы, делись.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            NavigationLink("Перейти в Editor") {
                EditorView()
            }
            .buttonStyle(.borderedProminent)
            NavigationLink("Перейти в Library") {
                LibraryView()
            }
        }
        .navigationTitle("Welcome")
        
    }
}



