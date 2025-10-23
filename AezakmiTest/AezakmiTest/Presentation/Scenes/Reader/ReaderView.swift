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
 
    var body: some View {
        VStack {
            PDFKitView(url: vm.document.fileURL, currentPageIndex: $vm.currentPageIndex)
        }
        .navigationTitle(vm.document.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
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
        .alert("Нельзя удалить страницу", isPresented: $showCantDeleteAlert) {
            Button("Ok", role: .cancel) {
                
            }
        }
        .sheet(isPresented: $showShare) {
            if let url = vm.shareURL() {
                ShareSheet(activityItems: [url])
            }
            
        }
    }
}


