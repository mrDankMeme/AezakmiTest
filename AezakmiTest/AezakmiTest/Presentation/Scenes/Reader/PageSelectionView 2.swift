\//
//  PageSelectionView 2.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//


import SwiftUI
import PDFKit

struct PageSelectionView: View {
    let sourceURL: URL
    let initialSelection: IndexSet
    let onCancel: () -> Void
    let onCreate: (_ pages: [Int]) -> Void

    @State private var thumbnails: [UIImage] = []
    @State private var pageCount: Int = 0
    @State private var selection = Set<Int>()
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Загрузка страниц…")
                        .progressViewStyle(.circular)
                } else {
                    GeometryReader { proxy in
                        let minWidth: CGFloat = 92
                        let columns = [GridItem(.adaptive(minimum: minWidth), spacing: 12)]
                        let thumbW = max(minWidth, (proxy.size.width - 12*4)/3)
                        let thumbH = thumbW * 1.3

                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(0..<pageCount, id: \.self) { i in
                                    pageThumb(index: i, size: CGSize(width: thumbW, height: thumbH))
                                }
                            }
                            .padding(12)
                        }
                    }
                }
            }
            .navigationTitle("Выбор страниц")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать PDF") {
                        onCreate(selection.sorted())
                    }
                    .disabled(selection.isEmpty)
                }
            }
            .onAppear(perform: load)
        }
    }

    @ViewBuilder
    private func pageThumb(index: Int, size: CGSize) -> some View {
        let selected = selection.contains(index)
        ZStack(alignment: .topTrailing) {
            if index < thumbnails.count {
                Image(uiImage: thumbnails[index])
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(8)
            }

            Text("\(index + 1)")
                .font(.caption2).padding(4)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
                .padding(4)

            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                    .padding(6)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(selected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            if selection.contains(index) {
                selection.remove(index)
            } else {
                selection.insert(index)
            }
        }
    }

    private func load() {
        isLoading = true
        selection = Set(initialSelection)
        DispatchQueue.global(qos: .userInitiated).async {
            var localThumbs: [UIImage] = []
            var count = 0
            if let doc = PDFDocument(url: sourceURL) {
                count = doc.pageCount
                for i in 0..<count {
                    if let p = doc.page(at: i) {
                        let img = p.thumbnail(of: CGSize(width: 160, height: 208), for: .cropBox)
                        localThumbs.append(img)
                    }
                }
            }
            DispatchQueue.main.async {
                self.pageCount = count
                self.thumbnails = localThumbs
                self.isLoading = false
            }
        }
    }
}
