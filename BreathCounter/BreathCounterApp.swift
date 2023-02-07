//
//  BreathCounterApp.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 24.01.2023.
//

import SwiftUI

@main
struct BreathCounterApp: App {
    
    @StateObject private var appConfig: AppConfig
    @StateObject private var appStore: AppStore
    @StateObject private var streamObserver: AudioStreamObserver
    @StateObject private var visualObserver: AudioVisualObserver
    
    init() {
        let config = AppConfig()
        let appStore = AppStore(dataService: MockDataService())
        let visualObs = AudioVisualObserver()
        let streamObs = AudioStreamObserver(store: appStore, with: visualObs)
        self._streamObserver = StateObject(wrappedValue: streamObs)
        self._visualObserver = StateObject(wrappedValue: visualObs)
        self._appStore = StateObject(wrappedValue: appStore)
        self._appConfig = StateObject(wrappedValue: config)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appStore)
                .environmentObject(appConfig)
                .environmentObject(streamObserver)
                .environmentObject(visualObserver)
        }
    }
}
