//
//  ContentView.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 24.01.2023.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group{
                    switch selectedTab {
                    case .home:
                        Home()
                    case .sessions:
                        SessionsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                TabBar()
            }
            .background(
                LinearGradient(colors: [Color("Background 1"), .clear],
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
        }
        .task { await store.loadYogas() }
        .refreshable(action: store.loadYogas)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(dev.store)
            .environmentObject(dev.streamObs)
            .environmentObject(dev.visualObs)
            .environmentObject(dev.config)

    }
}
