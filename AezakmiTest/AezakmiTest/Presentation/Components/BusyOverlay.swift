//
//  BusyOverlay.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//

import SwiftUI

struct BusyOverlay: View {
    var title: String = "Обработка..."
    var body : some View {
        ZStack {
            Color(.black).opacity(0.2).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                Text(title).font(.subheadline)
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .transition(.opacity)
        .animation(.easeInOut,value: UUID())
    }
}
