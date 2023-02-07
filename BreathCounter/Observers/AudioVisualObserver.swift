//
//  AudioVisualObserver.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 29.12.2022.
//

import SwiftUI

class AudioVisualObserver: AudioVisualObserving, ObservableObject {
    
    /// A reusable array that contains the current frame of time domain audio data as single-precision
    /// values.
    @Published var loudnessMagnitude: Float = 0

    /// A resuable array that contains the frequency domain representation of the current frame of
    /// audio data.
    @Published var frequencyDomainBuffer = [Float]()
    
    @Published var fullSignal = [Float]()
    
    func visualize(signal: AudioSignal) {
        self.loudnessMagnitude = signal.loudnessMagnitude
        self.frequencyDomainBuffer = signal.frequencyVertices
        self.fullSignal = signal.fullSignal
    }
}
