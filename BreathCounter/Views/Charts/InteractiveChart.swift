//
//  InteractiveChart.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 06.02.2023.
//

import SwiftUI
import Charts

struct InteractiveChart: View {

    @EnvironmentObject private var config: AppConfig
    var session: Yoga
    @Binding var selectedElement: Int?
    
    var avgRate: Double {
        if let selectedElement, session.rates.indices.contains(selectedElement) {
            return session.rates[...selectedElement].reduce(0.0, +) / Double(session.rates[...selectedElement].count)
        } else {
            return session.rates.count > 0 ? session.rates.reduce(0.0, +) / Double(session.rates.count) : 0.0
        }
    }
    
    func findElementIndex(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> Int? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for breatheIndex in session.breathings.indices {
                let nthSalesDataDistance = session.breathings[breatheIndex].duration.start.distance(to: date)
                if abs(nthSalesDataDistance) < minDistance {
                    minDistance = abs(nthSalesDataDistance)
                    index = breatheIndex
                }
            }
            return index
        }
        return nil
    }
    
    var body: some View {
        Chart {
            ForEach(session.rates.indices, id: \.self) { (index) in
                let breathing = session.breathings[index]
                let breathRate = session.rates[index]
                AreaMark(
                    x: .value("Time", breathing.duration.start),
                    yStart: .value("start", 0),
                    yEnd: .value("Rate", breathRate)
                )
                .foregroundStyle(selectedElement ?? 0 > index ?
                    .linearGradient(colors: [.gray.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom) :
                        .linearGradient(colors: [.accentColor.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                LineMark(
                    x: .value("Time", breathing.duration.start),
                    y: .value("Rate", breathRate)
                )
                .foregroundStyle(selectedElement ?? 0 > index ?
                    .linearGradient(colors: [.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing) :
                    .linearGradient(colors: [.accentColor, .purple], startPoint: .leading, endPoint: .trailing))
            }
            .interpolationMethod(.catmullRom)
            if let index = selectedElement {
                let breathing = session.breathings[index]
                let rate = session.rates[index]
                RuleMark(x: .value("Selection Start", breathing.duration.start),
                         yStart: .value("min", rate),
                         yEnd: .value("max", session.rates.max() ?? 0))
                .foregroundStyle(.linearGradient(colors: [.accentColor, .purple], startPoint: .top, endPoint: .bottom).opacity(0.5))
                PointMark(x: .value("X", breathing.duration.start),
                          y: .value("Y", rate))
                .symbol(.circle)
                .symbolSize(100)
                .foregroundStyle(.linearGradient(colors: [.accentColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                
                RuleMark(y: .value("avg", avgRate))
                    .foregroundStyle(Color.accentColor.gradient)
                    .lineStyle(.init(lineWidth: 0.5, lineCap: .round, lineJoin: .round, miterLimit: 5, dash: [5], dashPhase: 0))
                    .annotation(position: .top, alignment: .leading, spacing: 10, content: {
                        Text("\(avgRate, specifier: "%0.1f")")
                            .font(.headline.bold())
                            .foregroundStyle(Color.primary.gradient.opacity(0.7))
                            .padding(.leading, 20)
                            .lineLimit(1)
                    })
            }
            if session.rates.min() ?? 0 > 0 && session.rates.max() ?? 0 > 0 {
                RuleMark(y: .value("min", session.rates.min() ?? 0))
                    .foregroundStyle(Color.secondary.gradient.opacity(0.5))
                    .lineStyle(.init(lineWidth: 0.5, lineCap: .round, lineJoin: .round, miterLimit: 2, dash: [5], dashPhase: 0))
                    .annotation(position: .bottom, alignment: .leading, content: {
                        Text("\(session.rates.min() ?? 0, specifier: "%0.1f")")
                            .font(.caption)
                            .foregroundStyle(Color.secondary.gradient.opacity(0.7))
                            .padding(.leading, 20)
                            .lineLimit(1)
                    })
                RuleMark(y: .value("max", session.rates.max() ?? 0))
                    .lineStyle(.init(lineWidth: 0.5, lineCap: .round, lineJoin: .round, miterLimit: 2, dash: [5], dashPhase: 0))
                    .annotation(position: .top, alignment: .leading, content: {
                        Text("\(session.rates.max() ?? 0, specifier: "%0.1f")")
                            .font(.caption)
                            .foregroundStyle(Color.secondary.gradient.opacity(0.7))
                            .padding(.leading, 20)
                            .lineLimit(1)
                    })
            }


        }
        .animation(.easeOut(duration: 0.2), value: selectedElement)
//        .id(obs.breathings.count)
//        .transition(.slide)
        .chartOverlay { proxy in
            GeometryReader { nthGeometryItem in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                selectedElement = findElementIndex(location: value.location, proxy: proxy, geometry: nthGeometryItem)
                            }
                            .onEnded{ value in
                                selectedElement = nil
                            }
                    )
            }
        }
        .chartBackground { chartProxy in
            VStack{
                if session.breathings.count < 1 {
                    Image("undraw_data_input_fxv2")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding()
                    Divider()
                    Spacer()
                }
            }
            .transition(.slide)
            .animation(.spring(), value: session.breathings)
        }
        .frame(idealHeight: 200)
        
    }
}


struct InteractiveChart_Previews: PreviewProvider {
    
    static var previews: some View {
        Group{
            if let session = dev.store.yogas.first {
                InteractiveChart(session: session, selectedElement: .constant(1))
//                InteractiveChart(obs: InteractiveChartObserver(), session: session)
                //                InteractiveChart(session: session, selectedElement: .constant(nil), config: dev.config)
            }
        }
        .environmentObject(dev.config)
    }
}
