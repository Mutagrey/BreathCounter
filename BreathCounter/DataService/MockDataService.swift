//
//  MockDataService.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 18.01.2023.
//

import SwiftUI
import Combine

class MockDataService: DataServiceProtocol {
    
    func loadData() async throws -> [Yoga] {
        let result = Task{
            var yogas = [Yoga]()
            for _ in 0..<100 {
                var curYoga = Yoga()
                curYoga.breathings = generateBraethings()
                curYoga.duration.start = curYoga.breathings.first?.duration.start ?? .now
                curYoga.duration.end = curYoga.breathings.last?.duration.end ?? curYoga.duration.end
                curYoga.rates = curYoga.getAllBreathRates(last: 10)
                yogas.append(curYoga)
            }
            return yogas
        }
        return await result.value
    }
    
    func save(_ yoga: Yoga) async throws {
        /// Nothing to do
    }
    
    func remove(_ yoga: Yoga) async throws {
        /// Nothing to do
    }
    
    private func generateBraethings() -> [Breathing] {
        var breathings: [Breathing] = []
        let sessionDate = Date(timeInterval: -TimeInterval.random(in: 1...900) * 60 * 60 * 24, since: .now)
        var breatheDate = Date(timeInterval: 0, since: sessionDate)
        for _ in 0..<Int.random(in: 100...400) {
            let breatheDuration = TimeInterval.random(in: 1...20)
            breathings.append(.init(duration: .init(start: breatheDate, duration: breatheDuration), sounds: [.init(identifier: "empty", confidence: 0.7)]))
            breatheDate = Date(timeInterval: breatheDuration, since: breatheDate)
        }
        return breathings
    }
}
