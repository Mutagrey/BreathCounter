//
//  ChartData.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 19.01.2023.
//

import SwiftUI

struct ChartData: Identifiable, Hashable {
    var id = UUID()
    var timestamp: Date
    var count: Int
    var sum: Double
    var min: Double
    var max: Double
    var avg: Double {
        count > 0 ? sum / Double(count) : 0
    }
    
    static func getChartDataFrom(_ yoga: Yoga) -> [ChartData] {
        let grouped = Dictionary(grouping: yoga.breathings,
                                 by: {Duration.seconds($0.duration.duration).formatted(.time(pattern: .hourMinute))})
        
        let groupedChartData = grouped.keys.map{ (key) -> ChartData in
            let values = grouped[key]
            let timestamp = values?.first?.duration.start ?? .now
            let count = values?.count ?? 0
            let sum = values?.reduce(0.0, { $0 + ($1.duration.duration)}) ?? 0.0
            let min = values?.map({ $0.duration.duration }).min() ?? 0.0
            let max = values?.map({ $0.duration.duration }).max() ?? 0.0
            return ChartData(timestamp: timestamp, count: count, sum: sum, min: min, max: max)
        }//.sorted(by: { $0.timestamp < $1.timestamp })
                
        let result = yoga.breathings.map{ breathing -> ChartData in
            let currentGroup = groupedChartData.first(where: { $0.timestamp.distance(to: breathing.duration.start) < 60 })
            return ChartData(timestamp: breathing.duration.start, count: currentGroup?.count ?? 0, sum: currentGroup?.sum ?? 0, min: currentGroup?.min ?? 0, max: currentGroup?.max ?? 0)//, breathing: breathing)
        }
        
        return result
    }
   
}
