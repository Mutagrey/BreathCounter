//
//  SessionsView.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 25.01.2023.
//

import SwiftUI

struct SessionsView: View {
    @EnvironmentObject var store: AppStore
    
    var session: Yoga {
        store.yogas.last ?? Yoga()
    }
    
    var body: some View {
        List {
            Section("Statistic") {
                BreathingRateChart(session: session, type: .minmaxRate) { EmptyView() }
            }
            Section("Sessions \(store.yogas.count)") {
                sessionsList()
            }
        }
        .listStyle(.insetGrouped)
        .refreshable(action: store.loadYogas)
        .navigationTitle("Sessions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.removeAllYogas()
                } label: {
                    Image(systemName: "trash")
                }
                .tint(Color.red.gradient)
                .disabled(store.yogas.count == 0)
            }
        }
    }
    
    @ViewBuilder
    private func sessionsList() -> some View{
        ForEach(store.yogas) { yoga in
            NavigationLink(destination: DetailsView(session: yoga)) {
                SessionCard(session: yoga)
            }
        }
        .onDelete(perform: store.deleteYogas)
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView()
            .environmentObject(dev.store)
    }
}
