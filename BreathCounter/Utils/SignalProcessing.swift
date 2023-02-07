//
//  SignalProcessing.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 29.12.2022.
//

import Foundation
import Accelerate


final class SignalProcessing {
    // Loudness metering of the signal
    static func rms(data: UnsafeMutablePointer<Float>, frameLength: UInt) -> Float {
        var val : Float = 0
        vDSP_measqv(data, 1, &val, frameLength)
        var db = 10*log10f(val)
        //inverse dB to +ve range where 0(silent) -> 160(loudest)
        db = 160 + db;
        //Only take into account range from 120->160, so FSR = 40
        db = db - 120
        let dividor = Float(40/0.3)
        var adjustedVal = 0.3 + db/dividor
        
        //cutoff
        if (adjustedVal < 0.3) {
            adjustedVal = 0.3
        } else if (adjustedVal > 0.6) {
            adjustedVal = 0.6
        }
        
        return adjustedVal
    }
    
    static func interpolate(current: Float, previous: Float) -> [Float]{
        var vals = [Float](repeating: 0, count: 11)
        vals[10] = current
        vals[5] = (current + previous)/2
        vals[2] = (vals[5] + previous)/2
        vals[1] = (vals[2] + previous)/2
        vals[8] = (vals[5] + current)/2
        vals[9] = (vals[10] + current)/2
        vals[7] = (vals[5] + vals[9])/2
        vals[6] = (vals[5] + vals[7])/2
        vals[3] = (vals[1] + vals[5])/2
        vals[4] = (vals[3] + vals[5])/2
        vals[0] = (previous + vals[1])/2
        
        return vals
    }
    
    // Frequency metering of the signal
    static func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer, bufferSize: Int) -> [Float]{
        
        //output setup
        var realIn = [Float](repeating: 0, count: bufferSize)
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)
        
        //fill in real input part with audio samples
        for i in 0 ..< bufferSize {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        
        //setup magnitude output
        let magniCount = Double(bufferSize / 2)
        var magnitudes = [Float](repeating: 0, count: Int(magniCount))

        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imagBP in
                if let realAddress = realBP.baseAddress, let imagAddress = imagBP.baseAddress {
                    //package it inside a complex vector representation used in the vDSP framework
                    var complex = DSPSplitComplex(realp: realAddress, imagp: imagAddress)
                    //calculate magnitude results
                    vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(magniCount))
                }
            }
        }

        //normalize
        var normalizedMagnitudes = [Float](repeating: 0, count: Int(magniCount))
        var scalingFactor =  Float(25.0/magniCount)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(magniCount))
        
        return normalizedMagnitudes
    }
}
