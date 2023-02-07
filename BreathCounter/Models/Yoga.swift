//
//  Yoga.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 27.12.2022.
//

import SwiftUI
import SoundAnalysis

struct Yoga: Identifiable, Codable, Equatable {
    var id = UUID()
    var duration: DateInterval = DateInterval()
    var breathings: [Breathing] = []
    var rates: [Double] = []
    
    /// Average breathe rate. Breathings per minute
    var avgRates: Double {
        rates.count > 0 ? rates.reduce(0.0, +) / Double(rates.count) : 0.0
    }

    func getAllBreathRates(last elements: Int) -> [Double] {
        var results: [Double] = []
        breathings.indices.forEach { index in
            let curData = breathings[...index].suffix(elements)
            let sum = curData.map({ $0.duration.duration }).reduce(0.0, +)
            let count = Double(curData.count)
            let rate: Double = sum > 0 ? count / sum * 60 : 0
            results.append(rate)
        }
        return results
    }
    
    
    
//    /// Gets all avarage breathe rates with last n elements
//    func getAllBreathRatesAsync(last elements: Int) async -> [Double] {
//        var results = [Double]()
//        for index in breathings.indices {
//            let rate = await getAvgBreatheRate(at: index, last: elements)
//            results.append(rate)
//        }
//        return results
//    }
//    
//    /// Gets avarage breathe rate at Index with last n elements
//    func getAvgBreatheRate(at index: Int, last elements: Int) async -> Double {
//        let result = Task{
//            guard breathings.indices.contains(index) else { return 0.0 }
//            let curData = breathings[...index].suffix(elements)
//            let sum = curData.map({ $0.duration.duration }).reduce(0.0, +)
//            let count = Double(curData.count)
//            let rate: Double = sum > 0 ? count / sum * 60 : 0
//            return rate
//        }
//        return await result.value
//    }
}

struct Breathing: Identifiable, Codable, Equatable {
    var id = UUID()
    var duration: DateInterval = DateInterval()
    var rate: Double = 0.0
    var sounds: [SoundClassifier] = []
}

struct SoundClassifier: Codable, Equatable {
    
    let identifier: String
    let confidence: Double
    let soundLabel: String
   
    init(identifier: String, confidence: Double) {
        self.identifier = identifier
        self.confidence = confidence
        self.soundLabel = SoundClassifier.getSoundLabel(identifier)
    }
    
    static func getSoundLabel(_ identifier: String) -> String {
        /// TODO
        return identifier
    }
}
