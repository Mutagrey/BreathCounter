//
//  AudioVisualView.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 29.12.2022.
//

import SwiftUI
import Charts

struct AudioVisualView: View {
    
    @ObservedObject var observer: AudioVisualObserver
    
    var body: some View {
        Chart{
            ForEach(observer.fullSignal.indices, id: \.self) { index in
                let curVal = sin(Float(observer.fullSignal[index]) * 100 / 2)
//                let curVal = observer.fullSignal[index]
                BarMark(x: .value("X", String(index)),
                        yStart: .value("Freq", (-curVal)),
                        yEnd: .value("Freq",  (curVal)))
                .cornerRadius(20)
            }
            .foregroundStyle(Color.accentColor.gradient)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .animation(.easeOut(duration: 0.35), value: observer.fullSignal)
        .chartYScale(domain: -1.0 ... 1.0)
//        .onChange(of: streamObserver.yogas) { newValue in
//            guard !isActive else { return }
//            isActive = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                isActive = false
//            }
//        }
    }

}

struct AudioVisualView_Previews: PreviewProvider {
    static var previews: some View {
        AudioVisualView(observer: dev.visualObs)
    }
}
