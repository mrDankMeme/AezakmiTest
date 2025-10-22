//
//  FilePicker.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI
import UniformTypeIdentifiers


struct FilePicker: UIViewControllerRepresentable {
    let supportedTypes: [UTType]
 
    @Binding var pickedURL: URL?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        vc.delegate = context.coordinator
        return vc
    }
  
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
  
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
  
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FilePicker
        init(_ parent: FilePicker) {
            self.parent = parent
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.pickedURL = urls.first
        }
    }
    
}
