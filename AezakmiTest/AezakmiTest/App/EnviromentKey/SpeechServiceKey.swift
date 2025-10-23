//
//  SpeechServiceKey.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//


import SwiftUI

private struct SpeechServiceKey: EnvironmentKey {
    static let defaultValue: SpeechServiceProtocol = SpeechRecognizer()
}

extension EnvironmentValues {
    var speechService: SpeechServiceProtocol {
        get { self[SpeechServiceKey.self] }
        set { self[SpeechServiceKey.self] = newValue }
    }
}
