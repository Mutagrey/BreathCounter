//
//  TimerView.swift
//  DesignCodeiOS15
//
//  Created by Sergey Petrov on 20.01.2023.
//

import SwiftUI

struct TimerView: View {
    var font: Font = .largeTitle
    var weight: Font.Weight = .regular
    var numberWidth: CGFloat = 20
    var timeInterval: TimeInterval
    var body: some View {
        HStack(spacing: 0) {
            let components = getComponents(timeInterval)
            timerNumber((components.hour ?? 0) / 10, 0)
            timerNumber((components.hour ?? 0) % 10, 1)
            Text(":").padding(.horizontal, 2)
            timerNumber((components.minute ?? 0) / 10, 2)
            timerNumber((components.minute ?? 0) % 10, 3)
            Text(":").padding(.horizontal, 2)
            timerNumber((components.second ?? 0) / 10, 4)
            timerNumber((components.second ?? 0) % 10, 5)
        }
        .font(font)
        .fontWeight(weight)
    }
    
    @ViewBuilder
    func timerNumber(_ value: Int, _ index: Int) -> some View {
        Text("\(value)")
            .font(font)
            .fontWeight(weight)
            .frame(width: numberWidth)
            .opacity(0)
            .overlay {
                GeometryReader{
                    let size = $0.size
                    let fraction = (Double(index) * 0.15) > 0.5 ? 0.5 : Double(index) * 0.15
                    VStack(spacing: 0){
                        ForEach(0...9, id: \.self) { number in
                            Text("\(number)")
                                .font(font)
                                .fontWeight(weight)
                                .frame(width: size.width, height: size.height)
                        }
                    }
                    .offset(y: -CGFloat(value)*size.height)
                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.2 + fraction, blendDuration: 0.2 + fraction), value: value)

                }
                .clipped()
            }
    }
    
    func getComponents(_ timeInterval: TimeInterval) -> DateComponents {
        var components = DateComponents()
        components.second = Int(timeInterval)
        let date = Calendar.current.date(from: components) ?? .now
        return Calendar.current.dateComponents([.hour, .minute, .second], from: date)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timeInterval: (20))
    }
}
