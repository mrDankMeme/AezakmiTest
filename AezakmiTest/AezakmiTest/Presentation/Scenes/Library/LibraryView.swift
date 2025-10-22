//
//  LibraryView.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI

struct LibraryView: View {
    
    @StateObject var vm: LibraryViewModel
    @State private var shareURL: URL?
    @State private var showShare: Bool = false
    @State private var showError: Bool = false
    
    var body: some View {
        List {
            if vm.docs.isEmpty {
                Section("Пока пусто") {
                    Text("Создай PDF в Editor")
                        .foregroundColor(.secondary)
                }
            } else {
                if let src = vm.mergingSource {
                    Section {
                        Text("Выберите второй документ для обьединения с \(src.name)")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                }
                ForEach(vm.docs) { doc in
                    row(for:doc)
                        .disabled(vm.isMerging)
                        .overlay(
                            Group {
                                if vm.isMerging {
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture { vm.selecTarget(doc) }
                                }
                            }
                        )
                    
                }
            }
        }
        .toolbar {
            if vm.isMerging {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        vm.cancelMerge()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Library")
        .sheet(isPresented: $showShare) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
}

private extension LibraryView {
    func row(for doc: Document) -> some View {
        NavigationLink(destination: ReaderContainer(document: doc)) {
            HStack(spacing:12) {
                //thumbNail
                if let img = doc.thumbNail {
                    Image(uiImage: img).resizable().scaledToFill()
                        .frame(width: 40,height: 52).cornerRadius(6)
                } else {
                    Rectangle().fill(.secondary.opacity(0.2)).frame(width: 40,height: 52).cornerRadius(6)
                }
                
                //meta
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(doc.name).font(.headline)
                        if vm.mergingSource?.id == doc.id {
                            Text("①").font(.caption)
                                .padding(.horizontal, 6)
                                .background(Color.blue.opacity(0.15))
                                .cornerRadius(4)
                        }
                        Text("\(doc.createdAt.formatted(date: .abbreviated, time: .shortened)) • pdf • \(doc.pageCount) стр.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    Spacer()
                }
            }
            .contextMenu {
                Button("Поделиться") {
                    if let url = vm.shareURL(doc.id) {
                        shareURL = url
                        showShare = true
                    }
                }
                Button("Удалить", role: .destructive) {
                    vm.delete(doc.id)
                }
                Button("Обьединить") {
                    vm.beginMerge(from: doc)
                }
            }
        }
    }
}

private extension LibraryItem {
    func presentShare(_ url: URL) {
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil
        )
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
}
