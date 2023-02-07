//
//  AudioVisualizer.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 29.12.2022.
//

import AVFoundation
import Accelerate


protocol AudioSignal {
    var bufferSize: UInt { get set }
    var loudnessMagnitude: Float { get set }
    var frequencyVertices: [Float] { get set }
    var fullSignal: [Float] { get set }
}

protocol AudioVisualObserving {
    func visualize(signal: AudioSignal)
}

class AudioVisualizer: AudioSignal {
    
    var bufferSize: UInt = 0
    var loudnessMagnitude: Float = 0
    var frequencyVertices: [Float] = []
    var fullSignal: [Float] = []
    
    private var observer: AudioVisualObserving?
    private var prevRMSValue : Float = 0

    func add(observer: AudioVisualObserving) {
        self.observer = observer
    }
    
    func visualize(buffer: AVAudioPCMBuffer, with bufferSize: UInt) async {
        
        /// Buffer size
        self.bufferSize = bufferSize
        
        guard let channelData = buffer.floatChannelData?[0] else {return}
        let frames = buffer.frameLength
        
        //rms
//        let rmsValue = SignalProcessing.rms(data: channelData, frameLength: UInt(frames))
//        let interpolatedResults = SignalProcessing.interpolate(current: rmsValue, previous: prevRMSValue)
//        prevRMSValue = rmsValue
        
        //pass values to the audiovisualizer for the rendering
//        for rms in interpolatedResults {
//            self.loudnessMagnitude = rms
//        }
//        loudnessMagnitude = rmsValue
        
        //fft
//        guard let fftSetup = vDSP_DFT_zop_CreateSetup(nil, UInt(bufferSize), vDSP_DFT_Direction.FORWARD) else { return }
//        let fftMagnitudes =  SignalProcessing.fft(data: channelData, setup: fftSetup, bufferSize: Int(bufferSize))
//        self.frequencyVertices = fftMagnitudes

        let task = Task{
            var fullSignal = [Float](repeating: 0, count: Int(bufferSize))
            //fill in real input part with audio samples
            for i in 0 ..< Int(bufferSize) {
                fullSignal[i] = channelData[i]
            }
            return fullSignal
        }
        self.fullSignal = await task.value
        
        DispatchQueue.main.async {
            self.observer?.visualize(signal: self)
        }
    }
    
    func clearData() {
//        signal = nil
    }
    

    
}
