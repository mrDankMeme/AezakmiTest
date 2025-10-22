//
//  ShareSheet.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import SwiftUI

struct ShareSheet:UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> some UIViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    
    }
}
