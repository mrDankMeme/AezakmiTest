//
//  SpeechServiceProtocol.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//

 

import Foundation

public protocol SpeechServiceProtocol {
    func start(
        onText: @escaping (String) -> Void,
        onError: @escaping (String) -> Void,
        onFinish: @escaping () -> Void
    )
    func stop()
    func cancel()
}
