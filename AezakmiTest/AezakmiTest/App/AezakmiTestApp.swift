//
//  AezakmiTestApp.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//

import SwiftUI


@main
struct AezakmiTestApp: App {
    
    @MainActor private let root = CompositionRoot.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, root.coreData.viewContext)
                .environment(\.documentRepository, root.documentRepository)
                .environment(\.pdfService, root.pdf)
        }
    }
}
