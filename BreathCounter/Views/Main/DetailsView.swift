//
//  DetailsView.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 25.01.2023.
//

import SwiftUI
import Charts

struct DetailsView: View {
    var session: Yoga
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var streamObserver: AudioStreamObserver
    
    var body: some View {
        List {
            Section("Session info"){
                SessionCard(session: session)
            }
            Section("Statistic"){
                BreathingRateChart(session: session, type: .breathingsPerMinute){
                    EmptyView()
                }
                BreathingRateChart(session: session, type: .avgDuration){
                    Text("Breath duration")
                }
                BreathingRateChart(session: session, type: .minmaxRate){
                    Text("Header")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("\(session.duration.start.formatted(date: .abbreviated, time: .shortened))")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: "FFFF", subject: Text("F"), message: Text("Hello"))
            }
        }
    }
    
    var header: some View{
        HStack {
            VStack(alignment: .leading){
                Text("\(session.duration.start.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Text("\(session.duration)")
                    .font(.headline.bold())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(session.breathings.count)")
                .font(.headline.bold())
        }
    }
    
    @ViewBuilder
    func breathingCard(_ breathing: Breathing) -> some View{
        HStack{
            
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(session: .init())
            .environmentObject(dev.streamObs)
            .environmentObject(dev.store)
    }
}
