//
//  AudioStreamObserver.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 24.01.2023.
//

import SwiftUI
import SoundAnalysis
import Combine

class AudioStreamObserver: NSObject, ObservableObject {
    
    @Published private(set) var yoga: Yoga = .init()
    @Published private(set) var soundDetectionIsRunning = false
    @Published private(set) var progressTime: TimeInterval = 0
    
    private var store: AppStore
    private var timer: Timer?
    private var appConfig = AppConfig()
    private var visualObserver: AudioVisualObserving? = nil
    private var cancellable: AnyCancellable?
    
    init(store: AppStore, with visualObserver: AudioVisualObserving? = nil) {
        self.visualObserver = visualObserver
        self.store = store
        super.init()
        subscribeToStore()
    }
    
    func subscribeToStore(){
        cancellable = store.$yogas
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] yogas in
                guard let self = self else { return }
                if let yoga = yogas.first {
                    self.yoga = yoga
                }
            })
    }
    
    func restartDetection(with config: AppConfig) {
        AudioStreamManager.shared.stopSoundClassification()
        self.yoga = .init()
        self.soundDetectionIsRunning = true
        self.appConfig = config
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            DispatchQueue.main.async {
                self.progressTime += timer.timeInterval
                self.yoga.duration.duration += timer.timeInterval
            }
        }
        AudioStreamManager.shared.startSoundClassification(streamObserver: self, visualObserver: visualObserver, inferenceWindowSize: config.inferenceWindowSize, overlapFactor: config.overlapFactor)
    }
    
    func stopDetection() {
        AudioStreamManager.shared.stopSoundClassification()
        self.timer?.invalidate()
        DispatchQueue.main.async {
            self.soundDetectionIsRunning = false
            self.progressTime = 0
            if self.yoga.breathings.count > 0 {
                /// Previous breathing duration ends.
                self.yoga.duration.end = .now
                self.yoga.breathings[self.yoga.breathings.count - 1].duration.end = self.yoga.duration.end
                /// Add yoga to Store and update it
                self.store.update(self.store.addNewYoga(), with: self.yoga)
                /// Save
                Task { await self.store.save(self.yoga) }
            }
        }
    }
    
    /// Breathing detection. Convert detection result and append it to `bresthings`
    private func breathingsDetection(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        let classifications = result.classifications.filter({ appConfig.identifiers.contains($0.identifier) && $0.confidence >= appConfig.confidence })
        if classifications.count > 0 {
            DispatchQueue.main.async {
                /// Previous breathing duration ends.
                self.yoga.duration.end = .now
                if self.yoga.breathings.count > 0 {
                    self.yoga.breathings[self.yoga.breathings.count - 1].duration.end = self.yoga.duration.end
                }
                /// New detected breathing
                let sounds = classifications.map({ SoundClassifier(identifier: $0.identifier, confidence: $0.confidence) }).sorted(by: { $0.confidence > $1.confidence })
                let breathing = Breathing(duration: DateInterval(), sounds: sounds)
                self.yoga.breathings.append(breathing)
                // Get Rates
                self.yoga.rates = self.yoga.getAllBreathRates(last: self.appConfig.averageElementsCount)
            }

        }
    }
}

// Observing Sound classification results
extension AudioStreamObserver: SNResultsObserving {
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        breathingsDetection(request, didProduce: result)
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Sound analysis failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("Sound analysis request completed succesfully!")
    }
}
