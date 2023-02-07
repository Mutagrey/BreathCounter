//
//  SettingsView.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 31.01.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var config: AppConfig
    @State private var averageElementsCount: Double = 0
    
    var body: some View {
        Form{
            Section("Main"){
                /// Confidence
                VStack(alignment: .leading) {
                    HStack {
                        Text("Confidence")
                        Spacer()
                        Text("\(config.confidence, specifier: "%.2f")")
                    }
                    Slider(value: config.$confidence, in: 0...1, step: 0.05) {
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("1")
                    }
                }
                /// Inference Window Size
                VStack(alignment: .leading) {
                    HStack {
                        Text("Inference Window Size")
                        Spacer()
                        Text("\(config.inferenceWindowSize, specifier: "%.2f")")
                    }
                    Slider(value: config.$inferenceWindowSize, in: 0.5...10, step: 0.05) {
                    } minimumValueLabel: {
                        Text("0.5")
                    } maximumValueLabel: {
                        Text("10")
                    }
                }
                
                /// Overlap Factor
                VStack(alignment: .leading) {
                    HStack {
                        Text("Overlap Factor")
                        Spacer()
                        Text("\(config.overlapFactor, specifier: "%.2f")")
                    }
                    Slider(value: config.$overlapFactor, in: 0...1, step: 0.05) {
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("1")
                    }
                }
                
                /// Average elements count
                VStack(alignment: .leading) {
                    HStack {
                        Text("Average breath elements count")
                        Spacer()
                        Text("\(averageElementsCount, specifier: "%.0f")")
                    }
                    Slider(value: $averageElementsCount, in: 1...60, step: 1) {
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("60")
                    } onEditingChanged: { isChanged in
                        self.config.averageElementsCount = Int(averageElementsCount)
                    }
                }
                .onAppear{
                    averageElementsCount = Double(config.averageElementsCount)
                }
            }
        }
    }
    
    @ViewBuilder
    func slider<Content: View>(content: Content) -> some View{
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(dev.config)
    }
}
