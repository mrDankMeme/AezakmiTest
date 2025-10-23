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
    
    var body: some View {
        content
        .navigationTitle(vm.document.name)
        .toolbar { readerToolbar }
        .alert("Нельзя удалить страницу", isPresented: $showCantDeleteAlert) {
            Button("Ok", role: .cancel) {
                
            }
        }
        .onChange(of: vm.errorMessage) { msg in
            showError = ( msg != nil )
            
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("Ok") { vm.errorMessage = nil }
        } message: { Text(vm.errorMessage ?? "Неизвестная ошибка") }
            .sheet(isPresented: $showShare) {
                if let url = vm.shareURL() {
                    ShareSheet(activityItems: [url])
                }
            }
            .sheet(isPresented: $showAddTextSheet) {
                addTextSheet
            }
            .overlay { if vm.isBusy { BusyOverlay(title: "Обновление...") } }
    }
    
    private var content: some View {
        VStack {
            PDFKitView(url: vm.document.fileURL, currentPageIndex: $vm.currentPageIndex)
        }
    }
    
    @ToolbarContentBuilder
    private var readerToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("Добавить страницу") {
                showAddTextSheet = true
            }
            Button("Повернуть") {
                vm.rotateCurrentPage(clockwise: true)
            }
            Button("Удалить страницу") {
                if vm.canDeleteCurrentPage() {
                    vm.deleteCurrentPage()
                } else {
                    showCantDeleteAlert = true
                }
            }
            Button("Поделиться") {
                showShare = true
            }
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        showAddTextSheet = false
                    }
                }
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


