//
//  DictationView.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//


import SwiftUI

struct DictationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var isRunning = false
    @State private var showError = false
    @State private var errorMessage = ""

    let onCommit: (String) -> Void
    private let speech = SpeechRecognizer()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $text)
                    .frame(minHeight: 160)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .disabled(isRunning == false)

                Spacer()

                HStack(spacing: 20) {
                    Button(isRunning ? "Стоп" : "Старт") {
                        if isRunning { stop() } else { start() }
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
        speech.onText = { new in
            text = new
        }
        speech.onError = { msg in
            errorMessage = msg
            showError = true
            isRunning = false
        }
        speech.onFinish = {
            isRunning = false
        }
        speech.start()
        isRunning = true
    }

    private func stop() {
        speech.stop()        // мягкая остановка без cancel
        isRunning = false
    }

    private func cancel() {
        speech.cancel()      // реальная отмена (при закрытии экрана)
        isRunning = false
    }
}
