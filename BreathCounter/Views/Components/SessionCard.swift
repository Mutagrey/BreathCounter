//
//  SessionCard.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 25.01.2023.
//

import SwiftUI

struct SessionCard: View {
    
    @EnvironmentObject private var store: AppStore
    
    var session: Yoga
    
    var body: some View {
        HStack{
            Gauge(value: session.avgRates, in: (session.rates.min() ?? 0)...(session.rates.max() ?? 100)) {
                Image(systemName: "bolt")
            } currentValueLabel: {
                Text("\(session.avgRates, specifier: "%0.0f")")
                    .foregroundStyle(Color.primary.gradient)
                    .font(.body.weight(.semibold))
            } minimumValueLabel: {
                Text("\((session.rates.min() ?? 0), specifier: "%0.0f")")
                    .foregroundColor(.secondary)

            } maximumValueLabel: {
                Text("\((session.rates.max() ?? 0), specifier: "%0.0f")")
                    .foregroundColor(.secondary)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(LinearGradient(colors: [.accentColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.9))

            Gauge(value: Double(session.duration.duration), in: 0...Double(store.maxSessionTime)) {
                HStack {
                    Image(systemName: "calendar")
                    Text("\(session.duration.start.formatted(date: .abbreviated, time: .standard))")
                    Spacer()
                    Image(systemName: "wind")
                    Text("\(session.breathings.count)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            } currentValueLabel: {
                HStack {
                    Image(systemName: "timer")
                    Text("\(Duration.seconds(session.duration.duration).formatted())")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.caption)
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .tint(Gradient(colors: [.indigo]))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SessionCard_Previews: PreviewProvider {
    static var previews: some View {
        SessionCard(session: .init())
            .environmentObject(dev.store)
    }
}
