//
//  EditorView.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @StateObject var vm: EditorViewModel
    
    @State private var name: String = ""
    @State private var showPhotoPicker: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var openReader: Bool = false

    
    var body: some View {
        VStack(spacing: 12) {
            TextField("Название документа.", text: $name)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("Выбрать из фото.") {
                    showPhotoPicker = true
                }
                Button("Импорт из файлов.") {
                    showFilePicker = true
                }
            }
            if !vm.pickedImages.isEmpty {
                Text("Выбрано изображений \(vm.pickedImages.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if let url = vm.importedFileURL {
                Text("Файл: \(url.lastPathComponent)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Ничего не выбрано.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button("Сконвертировать / Сохранить") {
                vm.createPDF(name: name.isEmpty ? nil : name)
                openReader = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.pickedImages.isEmpty && vm.importedFileURL == nil)
            Spacer()
            
        }
        .padding()
        .navigationTitle("Editor")
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(images: $vm.pickedImages)
        }
        .sheet(isPresented: $showFilePicker) {
            FilePicker(supportedTypes: [.pdf, .image], pickedURL: $vm.importedFileURL)
        }
        .background(
            NavigationLink(isActive: $openReader) {
                if let doc = vm.createdDocument {
                    ReaderContainer(document: doc)
                } else {
                    EmptyView()
                }
            } label: {
                EmptyView()
            }
        )
    }
}
