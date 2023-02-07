//
//  AudioStreamManager.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 28.12.2022.
//

import SwiftUI
import SoundAnalysis

final class AudioStreamManager: NSObject {
    
    enum AudioManagerError: Error {
        case audioStreamInterrupted
        case noMicrophoneAccess
    }
    
    static let shared = AudioStreamManager()
    
    private var audioEngine: AVAudioEngine?
    private var analyzer: SNAudioStreamAnalyzer?
    
    private var streamObserver: SNResultsObserving?
    private var visualObserver: AudioVisualObserving?
    private var visualizer: AudioVisualizer?
    private var requestsAndObservers: [(SNRequest, SNResultsObserving)]?
    
    private override init() {}
    
    /// Requests premission to access microphone input, throwing an error if the user denies access/
    private func ensureMicrophoneAccess() throws {
        var hasMicrophone = false
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            let sem = DispatchSemaphore(value: 0)
            AVCaptureDevice.requestAccess(for: .audio) { success in
                hasMicrophone = success
                sem.signal()
            }
            _ = sem.wait(timeout: DispatchTime.distantFuture)
        case .denied, .restricted:
            break
        case .authorized:
            hasMicrophone = true
        default:
            fatalError("unknown authorization status for microphone access")
        }
        
        if !hasMicrophone {
            throw AudioManagerError.noMicrophoneAccess
        }
    }
    
    /// Configures and activates an AVAudioSession
    ///
    /// If this method throws an error, it calls `stopAudioSession` to reverce its effects.
    private func startAudioSession() throws {
        stopAudioSession()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            stopAudioSession()
            throw error
        }
    }
    
    /// Deactivates the app's AVAudioSession
    private func stopAudioSession() {
        autoreleasepool {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setActive(false)
        }
    }
    
    private func startListeningForAudioSessionInterruptions() {

    }
    
    private func stopListeningForAudioSessionInterruptions() {
        
    }
    
    @objc
    private func handleAudioSessionInterruption(_ notification: Notification) {
//        let error = AudioManagerError.audioStreamInterrupted
//        streamObservers?.first?.request?(requestsAndObservers?.first?.0 ?? any SNRequest(), didFailWithError: error)
        stopSoundClassification()
    }
    
    
    private func startAnalysing(_ requestsAndObservers: [(SNRequest, SNResultsObserving)], visualizer: AudioVisualizer?) throws {
        do {
            try startAudioSession()
//            try ensureMicrophoneAccess()
            
            let newEngine = AVAudioEngine()
            audioEngine = newEngine
            
            let busIndex = AVAudioNodeBus(0)
            let bufferSIze = AVAudioFrameCount(32)
            let audioFormat = newEngine.inputNode.outputFormat(forBus: busIndex)
            
            let newAnalyzer = SNAudioStreamAnalyzer(format: audioFormat)
            analyzer = newAnalyzer
            
            self.requestsAndObservers = requestsAndObservers
            try requestsAndObservers.forEach{ try newAnalyzer.add($0.0, withObserver: $0.1) }
//            retainedObservers = requestsAndObservers.map{ $0.1 }
            
            newEngine.inputNode.installTap(onBus: busIndex, bufferSize: bufferSIze, format: audioFormat, block: { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//                self.analysisQueue.async {
//                    newAnalyzer.analyze(buffer, atAudioFramePosition: when.sampleTime)
//                }
                Task{
                    newAnalyzer.analyze(buffer, atAudioFramePosition: when.sampleTime)
                }
                Task{
                    await visualizer?.visualize(buffer: buffer, with: UInt(16))
                }
            })
            
            try newEngine.start()
            
        } catch {
            stopAnalysing()
            throw error
        }
    }
    
    private func stopAnalysing() {
        autoreleasepool {
            if let audioEngine {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
            }
            
            if let analyzer {
                analyzer.removeAllRequests()
            }
            
            analyzer = nil
            audioEngine = nil
            streamObserver = nil
        }
        stopAudioSession()
    }
    
    func startSoundClassification(streamObserver: SNResultsObserving, visualObserver: AudioVisualObserving?, inferenceWindowSize: Double, overlapFactor: Double) {
        stopSoundClassification()
        do {
            self.streamObserver = streamObserver
            self.visualObserver = visualObserver
            let visualizer = AudioVisualizer()
            self.visualizer = visualizer
            if let visualObserver {
                self.visualizer?.add(observer: visualObserver)
            }
            
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            request.windowDuration = CMTimeMakeWithSeconds(inferenceWindowSize, preferredTimescale: 48_000)
            request.overlapFactor = overlapFactor
            
            try startAnalysing([(request, streamObserver)], visualizer: visualizer)
        } catch {
            stopSoundClassification()
        }
    }
    
    /// Stops any active sound classification task.
    func stopSoundClassification() {
        stopAnalysing()
        stopListeningForAudioSessionInterruptions()
    }
    
    /// Emits the set of labels producible by sound classification,
    ///
    ///  - returns: The set of all labels that sound classification emits.
    static func getAllPossibleLabels() throws -> Set<String> {
        let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
        return Set<String>(request.knownClassifications)
    }

}
