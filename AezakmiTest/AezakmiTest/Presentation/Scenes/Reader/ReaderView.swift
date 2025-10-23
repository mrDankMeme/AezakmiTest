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
    @State var showShare: Bool = false
    @State var showCantDeleteAlert: Bool = false
    @State var showError = false
    @State var showAddTextSheet = false
    @State var newPageText: String = ""
    
    @State private var showDeletePagePrompt: Bool = false
    @State private var pageToDeleteText: String = ""
    
    var body: some View {
        content
            .navigationTitle(vm.document.name)
            .toolbar { readerToolbar }
            .alert("Нельзя удалить страницу", isPresented: $showCantDeleteAlert) {
                Button("Ok", role: .cancel) {}
            }
            .onChange(of: vm.errorMessage) { msg in
                showError = (msg != nil)
            }
            .alert("Ошибка", isPresented: $showError) {
                Button("Ok") { vm.errorMessage = nil }
            } message: { Text(vm.errorMessage ?? "Неизвестная ошибка") }
            .sheet(isPresented: $showShare) {
                if let url = vm.shareURL() { ShareSheet(activityItems: [url]) }
            }
            .sheet(isPresented: $showAddTextSheet) { addTextSheet }
            .overlay { if vm.isBusy { BusyOverlay(title: "Обновление...") } }
            .alert("Введите номер страницы", isPresented: $showDeletePagePrompt) {
                TextField("Номер страницы", text: $pageToDeleteText)
                    .keyboardType(.numberPad)
                Button("Удалить") {
                    if let index = Int(pageToDeleteText), index > 0 {
                        vm.deletePage(at: index - 1) // индекс с 0
                    } else {
                        vm.errorMessage = "Введите корректный номер страницы"
                        showError = true
                    }
                    pageToDeleteText = ""
                }
                Button("Отмена", role: .cancel) { pageToDeleteText = "" }
            } message: {
                Text("Введите номер страницы для удаления (1–\(vm.document.pageCount))")
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            PDFKitView(url: vm.document.fileURL, currentPageIndex: $vm.currentPageIndex)
            pageControl
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    private var pageControl: some View {
        HStack(spacing: 12) {
            Button {
                vm.currentPageIndex = max(0, vm.currentPageIndex - 1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(vm.currentPageIndex <= 0)
            
            Text("Стр. \(vm.currentPageIndex + 1) / \(max(1, vm.document.pageCount))")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button {
                vm.currentPageIndex = min(max(0, vm.document.pageCount - 1), vm.currentPageIndex + 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(vm.currentPageIndex >= vm.document.pageCount - 1)
            
            Spacer()
        }
    }
    
    @ToolbarContentBuilder
    private var readerToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("Добавить страницу") { showAddTextSheet = true }
            Button("Повернуть") { vm.rotateCurrentPage(clockwise: true) }
            Button("Удалить страницу") { showDeletePagePrompt = true }
            Button("Поделиться") { showShare = true }
        }
    }
    
    private var addTextSheet: some View {
        NavigationView {
            VStack {
                TextEditor(text: $newPageText)
                    .font(.body)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(18)
                    .padding()
                Spacer()
            }
            .navigationTitle("Новая страница")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { showAddTextSheet = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        let text = newPageText
                        newPageText = ""
                        showAddTextSheet = false
                        vm.addTextPage(text)
                    }
                    .disabled(newPageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
