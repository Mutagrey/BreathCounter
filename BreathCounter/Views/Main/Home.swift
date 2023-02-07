//
//  Home.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 25.01.2023.
//

import SwiftUI
import Charts

struct Home: View {
    @EnvironmentObject private var config: AppConfig
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var obs: AudioStreamObserver
    
    var session: Yoga { obs.yoga }
    
    @State private var show = true
    @State private var selectedElemet: Int?
    
    var totalBreathings: Int {
        if let selectedElemet, session.breathings.indices.contains(selectedElemet) {
            return session.breathings[...selectedElemet].count
        } else {
            return session.breathings.count
        }
    }
    
    var currentBreathing: Breathing {
        if let selectedElemet, session.breathings.indices.contains(selectedElemet) {
            return session.breathings[selectedElemet]
        } else {
            return session.breathings.last ?? .init()
        }
    }
    
    var breathRate: Double {
        if let selectedElemet, session.rates.indices.contains(selectedElemet) {
            return session.rates[selectedElemet]
        } else {
            return session.rates.last ?? 0.0
        }
    }
    
    var lastMinuteRate: Double {
        if let selectedElemet, session.rates.indices.contains(selectedElemet - 1) {
            return breathRate - session.rates[selectedElemet - 1]
        } else {
            return breathRate - (session.rates.suffix(2).first ?? 0.0)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20){
                BreatheView(isAnimate: obs.soundDetectionIsRunning)
                sessionTimeView(session)
                sessionInfo(session)
                InteractiveChart(session: session, selectedElement: $selectedElemet)
                    .frame(height: 180)
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
//                .padding(.horizontal)
            }
            .animation(.easeInOut(duration: 0.5), value: session)
        }
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gear")
                        .imageScale(.medium)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                        .strokeStyleShape(shape: Circle() )
                }
            }
        }
    }
    
    @ViewBuilder
    func sessionInfo(_ session: Yoga) -> some View{
        HStack{
            homeCardView("last rate", icon: "arrowtriangle.up.fill", value: String(format: "%.1f", locale: .current, lastMinuteRate))
                .foregroundStyle(lastMinuteRate < 0 ? Color.red.gradient : Color.green.gradient)
            homeCardView("Breath rate", icon: "hare", value: String(format: "%0.0f", locale: .current, breathRate))
            homeCardView("total breathings", icon: "wind", value: String(totalBreathings))
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func sessionTimeView(_ session: Yoga) -> some View{
        VStack(spacing: 5){
            let format = Date.FormatStyle(date: .abbreviated, time: .shortened, locale: .current, calendar: .current, timeZone: .current, capitalizationContext: .beginningOfSentence)
            let curD = format.format(currentBreathing.duration.start)
            Text(curD)
                .foregroundColor(.secondary)
                .font(.title3)
            HStack{
                Image(systemName: "timer")
                    .font(.title3.weight(.semibold))
                TimerView(timeInterval: currentBreathing.duration.start.timeIntervalSince(session.duration.start))
            }
            .font(.title.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func homeCardView(_ title: String, icon: String, value: String, font: Font = .title2) -> some View{
        VStack(alignment: .leading, spacing: 8){
            Text(title.uppercased())
                .font(.caption2.weight(.light))
                .foregroundStyle(Color.primary.gradient)
            Spacer()
            HStack{
                Image(systemName: icon)
                    .font(.headline.weight(.semibold))
                Text(value)
                    .font(font.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .foregroundStyle(Color.primary.gradient)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
//        .frame(height: 100)
        .cardify(cornerRadius: 15, padding: 10)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(dev.config)
            .environmentObject(dev.store)
            .environmentObject(dev.streamObs)
    }
}
