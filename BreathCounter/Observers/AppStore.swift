//
//  AppObserver.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 18.01.2023.
//

import SwiftUI

 class AppStore: ObservableObject {
    
    @Published private(set) var yogas: [Yoga] = [] 

    var maxBreathings: Int {
        yogas.map({ $0.breathings.count }).max() ?? 20 * 20
    }
    
    var minBreathings: Int {
        yogas.map({ $0.breathings.count }).min() ?? 0
    }
    
    var maxSessionTime: TimeInterval {
        yogas.map({ $0.duration.duration }).max() ?? 20 * 60 * 60
    }
    
    var minSessionTime: TimeInterval {
        yogas.map({ $0.duration.duration }).min() ?? 0
    }
    
    var maxBreatheRate: Double {
        yogas.map({ Double($0.breathings.count) / Double($0.duration.duration) * 60 }).max() ?? 100
    }
    
    var minBreatheRate: Double {
        yogas.map({ Double($0.breathings.count) / Double($0.duration.duration) * 60 }).min() ?? 0
    }
    
    let dataService: DataServiceProtocol

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    @MainActor
    @Sendable func loadYogas() async {
        do {
            let result = try await dataService.loadData()
            self.yogas = result
            self.yogas.sort(by: {$0.duration.start > $1.duration.start })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(_ yoga: Yoga) async {
//        self.yogas.insert(yoga, at: 0)
        try? await dataService.save(yoga)
    }
    
    func update(_ yoga: Yoga?, with newYoga: Yoga) {
        if let index = yogas.firstIndex(where: { $0.id == yoga?.id }) {
            yogas[index] = newYoga
        }
    }
    
    @discardableResult
    func addNewYoga() -> Yoga {
        let yoga = Yoga()
        self.yogas.insert(yoga, at: 0)
        return yoga
    }
    
    func deleteYogas(_ indexSet: IndexSet) {
        self.yogas.enumerated().filter({ indexSet.contains($0.offset) }).forEach{ index, yoga in
            Task { try? await dataService.remove(yoga) }
        }
        self.yogas.remove(atOffsets: indexSet)
    }
    
    func removeAllYogas(){
        self.yogas.forEach{ yoga in
            Task { try? await dataService.remove(yoga) }
        }
        self.yogas.removeAll()
    }
    
    
}

