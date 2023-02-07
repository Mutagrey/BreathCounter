//
//  BreathingVisualization.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 30.01.2023.
//

import SwiftUI

struct ListenButton: View {
    
    @EnvironmentObject var obs: AudioStreamObserver
    @EnvironmentObject var config: AppConfig
    @State private var isRunning = false
    @State private var isActive = false
    
    var body: some View {
        Button {
            if obs.soundDetectionIsRunning {
                obs.stopDetection()
                withAnimation {
                    isActive = false
                }
            } else {
                obs.restartDetection(with: config)
                withAnimation {
                    isActive = true
                }
            }
            withAnimation(isActive ? .easeIn(duration: 1).delay(1).repeatForever(autoreverses: false) : .default){
                isRunning.toggle()
            }
        } label: {
            ZStack{
                Circle()
                    .stroke(lineWidth: isRunning ? 30 : 0)
                    .fill(Color.accentColor.gradient.opacity(isRunning ? 1 : 0.3))
                    .frame(width: isRunning ? 150 : 100, height: isRunning ? 150 : 100)
                    .opacity(isRunning ? 0 : 1)
                    .blur(radius: isRunning ? 10 : 0)
                
                Circle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(Color.primary.gradient)
                    .frame(width: 100, height: 100)
                    .blendMode(.overlay)

                Circle()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(isActive ?  Color.accentColor.gradient : Color.accentColor.gradient)

                Image(systemName: "mic")
                    .font(.title)
                    .symbolVariant( isActive ? .slash : .fill)
            }
            .frame(width: 100, height: 100)
        }
        .buttonStyle(.plain)
    }
}

struct ListenButton_Previews: PreviewProvider {
    static var previews: some View {
        ListenButton()
            .environmentObject(dev.config)
            .environmentObject(dev.streamObs)
    }
}
