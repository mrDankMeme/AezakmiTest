//
//  DictationView.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//


import SwiftUI

struct DictationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.speechService) private var speech: SpeechServiceProtocol

    @State private var text = ""
    @State private var isRunning = false
    @State private var showError = false
    @State private var errorMessage = ""

    let onCommit: (String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $text)
                    .frame(minHeight: 160)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .disabled(!isRunning)

                Spacer()

                HStack(spacing: 20) {
                    Button(isRunning ? "Стоп" : "Старт") {
                        isRunning ? stop() : start()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Очистить") {
                        text = ""
                    }
                    .disabled(text.isEmpty || isRunning)
                }
            }
            .padding()
            .navigationTitle("Диктовка")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        cancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        stop()
                        onCommit(text.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Ошибка", isPresented: $showError) {
                Button("Ок", role: .cancel) { showError = false }
            } message: {
                Text(errorMessage)
            }
        }
        .onDisappear { cancel() }
    }

    private func start() {
        speech.start(
            onText: { new in text = new },
            onError: { msg in
                errorMessage = msg
                showError = true
                isRunning = false
            },
            onFinish: { isRunning = false }
        )
        isRunning = true
    }

    private func stop() {
        speech.stop()
        isRunning = false
    }

    private func cancel() {
        speech.cancel()
        isRunning = false
    }
}
