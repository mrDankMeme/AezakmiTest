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


struct EditorView: View {
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

struct ReaderView: View {
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

struct LibraryView: View {
    var body: some View {
        List {
            Section("Здесь пока пусто") {
                Text("Здесь появится список сохранённых PDF.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Library")
            
        }
    }
}
