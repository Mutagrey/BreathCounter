//
//  BreatheView.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 02.02.2023.
//

import SwiftUI

struct BreatheView: View {
    var isAnimate: Bool
    @State private var startAnimation: Bool = false

    @State private var circlesCount: Int = 6
//    @State private var showBreathView = false
    @State private var timerCount: CGFloat = 0
    
    var body: some View {
        VStack{
            GeometryReader{ geo in
                breathCircles(circlesCount, geo.size, .accentColor)
            }
            .frame(width: 300, height: 200)
            .onChange(of: isAnimate) { isAnimate in
                if isAnimate {
                    withAnimation(.easeInOut(duration: 2).delay(0.1).repeatForever()){
                        startAnimation.toggle()
                    }
                } else {
//                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                    withAnimation(.easeInOut(duration: 1)){
                        startAnimation = false
                    }
                }
            }
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common)) { _ in
            if timerCount < 3.2 {
                timerCount += 0.01
            } else {
                withAnimation(.easeInOut(duration: 1)){
//                    startAnimation.toggle()
                    timerCount = 0
                }
            }
        }
    }
    
    @ViewBuilder
    func breathCircles(_ count: Int, _ size: CGSize, _ color: Color) -> some View{
        let degrees = 360.0 / Double(count)
        let curSize = min(size.width, size.height)
        ZStack{
            
//            Circle()
//                .fill(color.gradient.opacity(0.7))
//                .blur(radius: startAnimation ? 0 : 10)
            
            Circle()
                .fill(.ultraThinMaterial)
//                .blur(radius: startAnimation ? 0 : 40)

            ForEach(1...count, id: \.self) { index in
                Circle()
                    .fill(color.gradient.opacity(0.7))
                    .frame(width: curSize / 2, height: curSize / 2)
                    .offset(x: startAnimation ? 0 : curSize / 4)
                    .rotationEffect(.degrees(degrees * Double(index)))
                    .rotationEffect(.degrees(startAnimation ? -degrees : 0))
                    .scaleEffect(startAnimation ? 0.7 : 0.9)
                    .shadow(radius: startAnimation ? 0 : 5)

            }
            
            let strokeCirclesCount = 4
            let strokeCirclesDegrees = 360.0 / Double(strokeCirclesCount)
            let progress = 1.0 / Double(strokeCirclesCount)
            ForEach(0..<strokeCirclesCount, id: \.self) { index in
                Circle()
                    .trim(from: Double(index) * progress, to: startAnimation ? Double(index) * progress : Double(index + 1) * progress)
                    .stroke(color.gradient, style: .init(lineWidth: startAnimation ? 0 : 5, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.degrees(startAnimation ? -strokeCirclesDegrees : 0))
            }
            
            Circle()
                .stroke(color, lineWidth: 0.5)
                .blendMode(.overlay)
                .shadow(radius: 10)
            
            let rate = 0.6
            Image("undraw_mindfulness_6xt3")
                .resizable()
                .scaledToFit()
                .frame(width: size.width * rate, height: size.height * rate)
                .shadow(radius: 5, x: 5, y: 5)
            
        }
        .frame(width: size.width, height: size.height)
//        .scaleEffect(startAnimation ? 0.8 : 1)
//        .shadow(radius: 20)
    }
    
//    func startBreathing() {
//        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
//            showBreathView.toggle()
//        }
//        if showBreathView {
//            withAnimation(.easeInOut(duration: 3).delay(0.05)){
//                startAnimation = true
//            }
//        } else {
//            withAnimation(.easeInOut(duration: 1.5)){
//                startAnimation = false
//            }
//        }
//    }
}

struct BreatheView_Previews: PreviewProvider {
    static var previews: some View {
        BreatheView(isAnimate: (true))
    }
}
