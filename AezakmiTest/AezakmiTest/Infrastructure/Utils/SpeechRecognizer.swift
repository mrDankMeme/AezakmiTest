//
//  SpeechRecognizer.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//


import Foundation
import AVFoundation
import Speech

final class SpeechRecognizer: NSObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    var onText: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onFinish: (() -> Void)?

    func start() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                DispatchQueue.main.async { self.beginSession() }
            } else {
                DispatchQueue.main.async {
                    self.onError?("Доступ к распознаванию речи не разрешён")
                }
            }
        }
    }

    func stop() {
        request?.endAudio()
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        if audioEngine.inputNode.outputFormat(forBus: 0).channelCount > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        // НЕ вызываем cancel — даём таске корректно завершиться.
    }

    func cancel() {
        task?.cancel()
        cleanup()
    }

    private func beginSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let req = SFSpeechAudioBufferRecognitionRequest()
            req.shouldReportPartialResults = true
            request = req

            let input = audioEngine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.request?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            task = recognizer?.recognitionTask(with: req) { [weak self] result, error in
                guard let self = self else { return }

                if let text = result?.bestTranscription.formattedString {
                    self.onText?(text)
                }

                if let err = error as NSError? {
                    // Игнорируем «отменено» при штатной остановке
                    let msg = err.localizedDescription.lowercased()
                    if err.domain == "kSFSpeechRecognitionErrorDomain" && err.code == 203 { return }
                    if msg.contains("canceled") { return }
                    self.onError?(err.localizedDescription)
                    self.cleanup()
                    return
                }

                if result?.isFinal == true {
                    self.onFinish?()
                    self.cleanup()
                }
            }
        } catch {
            onError?("Не удалось запустить аудиосессию: \(error.localizedDescription)")
            cleanup()
        }
    }

    private func cleanup() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        if audioEngine.inputNode.outputFormat(forBus: 0).channelCount > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        task = nil
        request = nil
    }
}
