//
//  PreviewProvider.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 04.01.2023.
//

import SwiftUI

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

//@MainActor
class DeveloperPreview {
    
    static let instance = DeveloperPreview()
    
    var streamObs: AudioStreamObserver
    var visualObs: AudioVisualObserver
    var store: AppStore
    var config: AppConfig
    
    private init() {
        store = AppStore(dataService: MockDataService())
        config = AppConfig()
        visualObs = AudioVisualObserver()
        streamObs = AudioStreamObserver(store: store, with: visualObs)
    }
}
