//
//  SpeechRecognizer.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//

import Foundation
import Speech
import AVFoundation

final class SpeechRecognizer: NSObject, SpeechServiceProtocol {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func start(
        onText: @escaping (String) -> Void,
        onError: @escaping (String) -> Void,
        onFinish: @escaping () -> Void
    ) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self else { return }
            if status == .authorized {
                DispatchQueue.main.async {
                    self.beginSession(onText: onText, onError: onError, onFinish: onFinish)
                }
            } else {
                DispatchQueue.main.async {
                    onError("Доступ к распознаванию речи не разрешён")
                }
            }
        }
    }

    private func beginSession(
        onText: @escaping (String) -> Void,
        onError: @escaping (String) -> Void,
        onFinish: @escaping () -> Void
    ) {
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
                guard let self else { return }

                if let text = result?.bestTranscription.formattedString {
                    onText(text)
                }

                if let err = error as NSError? {
                    let msg = err.localizedDescription.lowercased()
                    if msg.contains("canceled") { return }
                    onError(err.localizedDescription)
                    self.cleanup()
                    return
                }

                if result?.isFinal == true {
                    onFinish()
                    self.cleanup()
                }
            }
        } catch {
            onError("Ошибка аудиосессии: \(error.localizedDescription)")
            cleanup()
        }
    }

    func stop() {
        request?.endAudio()
        if audioEngine.isRunning { audioEngine.stop() }
        if audioEngine.inputNode.outputFormat(forBus: 0).channelCount > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }

    func cancel() {
        task?.cancel()
        cleanup()
    }

    private func cleanup() {
        if audioEngine.isRunning { audioEngine.stop() }
        if audioEngine.inputNode.outputFormat(forBus: 0).channelCount > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        task = nil
        request = nil
    }
}
