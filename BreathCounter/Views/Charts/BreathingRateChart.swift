//
//  BreathingRateChart.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 27.01.2023.
//

import SwiftUI
import Charts

struct BreathingRateChart<Header: View>: View {

    enum ChartType {
        case breathingsPerMinute
        case avgDuration
        case minmaxRate
    }
    
    var session: Yoga
    var type: ChartType = .breathingsPerMinute
    var header: () -> Header
    
    var body: some View {
        VStack{
            HStack {
                header()
                Spacer()
            }
            switch type {
            case .breathingsPerMinute: brpmView
            case .avgDuration: avdDurationView
            case .minmaxRate: minmaxRateView
            }
        }
        .frame(idealHeight: 200)
        .chartBackground { chartProxy in
            Group{
                if session.breathings.count <= 1 {
                    Image("undraw_data_input_fxv2")
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
            .animation(.easeIn, value: session.breathings)
        }
    }
    
    var brpmView: some View{
        Chart{
            ForEach(session.breathings.indices, id: \.self) { index in
                let breathing = session.breathings[index]
                let curData = session.breathings[...index].suffix(5)
                let sum = curData.map({ $0.duration.duration }).reduce(0.0, +)
                let count = Double(curData.count)
                let rate: Double = sum > 0 ? count / sum * 60 : 0
                AreaMark(x: .value("Date", breathing.duration.start),
                         yStart: .value("Start", 0),
                         yEnd: .value("End", rate)
                )
                .foregroundStyle(.linearGradient(colors: [.accentColor.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                
                LineMark(x: .value("Date", breathing.duration.start),
                         y: .value("Duration", rate))
                .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
            .interpolationMethod(.catmullRom)
        }
        .chartOverlay(content: chartOverlayView)
    }
    
    @ViewBuilder
    func chartOverlayView(_ proxy: ChartProxy) -> some View {
        GeometryReader{ geometry in
            Rectangle().fill(.clear).contentShape(Rectangle())
//                .gesture(
//                DragGesture()
//                    .onChanged{ value in
//                        // Find the x-coordinates in the chart’s plot area.
//                        let startPoint = value.startLocation.x - geometry[proxy.plotAreaFrame].origin.x
//                        let currentPoint = value.location.x - geometry[proxy.plotAreaFrame].origin.x
//                        // Convert to actual point
//                        if let actualStart = proxy.value(atX: startPoint, as: Double.self),
//                           let actualCurrent = proxy.value(atX: currentPoint, as: Double.self) {
//                            return (actualCurrent.0 - actualStart.0, actualCurrent.1 - actualStart.1)
//                        }
//                        return (0, 0)
//                    }
//                
//                )
//                .gesture(dragGesture(proxy, geometry).simultaneously(with: magnificationGesture(proxy, geometry)))
        }
    }
    
    
    var avdDurationView: some View{
        Chart{
            ForEach(session.breathings.indices, id: \.self) { index in
                let breathing = session.breathings[index]
                let curData = session.breathings[...index].suffix(5)
                let sum = curData.map({ $0.duration.duration }).reduce(0.0, +)
                let count = Double(curData.count)
                let avg: Double = count > 0 ? sum / count : 0
                AreaMark(x: .value("Date", breathing.duration.start),
                         yStart: .value("Start", 0),
                         yEnd: .value("End", avg)
                )
                .foregroundStyle(.linearGradient(colors: [.accentColor.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                
                LineMark(x: .value("Date", breathing.duration.start),
                         y: .value("Duration", avg))
            }
            .interpolationMethod(.catmullRom)
        }
    }
    
    var minmaxRateView: some View{
        Chart{
            ForEach(session.breathings.indices, id: \.self) { index in
                let breathing = session.breathings[index]
                let curData = session.breathings[...index].suffix(15)
                let sum = curData.map({ $0.duration.duration }).reduce(0.0, +)
                let count = Double(curData.count)
                let avg: Double = count > 0 ? sum / count : 0
                let min = curData.map{ $0.duration.duration }.min() ?? 0
                let max = curData.map{ $0.duration.duration }.max() ?? 0
                BarMark(x: .value("Date", breathing.duration.start, unit: .minute),
                         yStart: .value("Start", min),
                         yEnd: .value("End", max)
                )
                .foregroundStyle(.gray.opacity(0.1))
                
                RectangleMark(x: .value("Date", breathing.duration.start),
                              y: .value("Duration", avg),
                              height: 5
                )
            }
        }
    }
    
}

struct BreathingRateChart_Previews: PreviewProvider {
    static let store = AppStore(dataService: MockDataService())
    static let yoga = store.yogas.first ?? Yoga()
    static var previews: some View {
        BreathingRateChart(session: yoga){
            Text("sdf")
        }
        .environmentObject(dev.store)
    }
}
