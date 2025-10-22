//
//  LibraryView.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.documentRepository) private var repo
    @StateObject private var vm: LibraryViewModel
    
    init() {
        _vm = StateObject(wrappedValue: LibraryViewModel(repo: CompositionRoot.shared.documentRepository))
    }
    var body: some View {
        List {
            if vm.docs.isEmpty {
                Section("Пока пусто") {
                    Text("Создай PDF в Editor")
                        .foregroundColor(.secondary)
                }
            } else {
                ForEach(vm.docs) { doc in
                    HStack {
                        if let img = doc.thumbNail {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40,
                                       height: 52)
                                .clipped()
                                .cornerRadius(6)
                        } else {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 40, height: 52)
                                .cornerRadius(6)
                        }
                        VStack(alignment: .leading) {
                            Text(doc.name).font(.headline)
                            Text("\(doc.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .contextMenu {
                        Button("Поделиться") {
                            if let url = vm.shareURL(doc.id) {
                                //TODO: present share
                            }
                        }
                        Button("Удалить", role: .destructive) {
                            vm.delete(doc.id)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Library")
    }
    
}

private extension LibraryItem {
    func presentShare(_ url: URL) {
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil
        )
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
}
