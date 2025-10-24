//
//  AezakmiTestApp.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/21/25.
//


import SwiftUI
import UIKit

@main
struct AezakmiTestApp: App {

    @MainActor private let root = CompositionRoot.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, root.coreData.viewContext)
                .environment(\.documentRepository, root.documentRepository)
                .environment(\.pdfService, root.pdf)
                // На всякий случай сохраняем при завершении процесса
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    root.coreData.saveContextIfNeeded()
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background, .inactive:
                root.coreData.saveContextIfNeeded()
            default:
                break
            }
        }
    }
}
