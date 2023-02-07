//
//  TabBar.swift
//  DesignCodeiOS15
//
//  Created by Sergey Petrov on 16.01.2023.
//

import SwiftUI

struct TabBar: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var obs: AudioStreamObserver
    @EnvironmentObject var visualObs: AudioVisualObserver
    @Namespace private var animation
    
    @AppStorage("selectedTab") private var selectedTab: Tab = .home
    @State private var color: Color = .teal
    
    private var tabItems: [TabItem] = [
        TabItem(text: "", icon: "house", tab: .home, color: .primary),
        TabItem(text: "", icon: "list.bullet", tab: .sessions, color: .primary.opacity(0.9)),
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            audioPanel
            tabBody
        }
        .ignoresSafeArea()
    }
    
    var audioPanel: some View{
        VStack{
            TimerView(timeInterval: obs.progressTime)
//            AudioVisualView(observer: visualObs)
//                .frame(height: 80)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding()
        .background{
            Image("undraw_voice_assistant_nrv7")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
        }
        .background{
            RoundedRectangle(cornerRadius: 34)
                .fill(.ultraThinMaterial)
                .opacity(obs.soundDetectionIsRunning ? 1 : 0)
                .strokeStyle(cornerRadius: 34)
        }
        .offset(y: obs.soundDetectionIsRunning ? 0 : 300)
        .animation(.easeInOut(duration: 0.4), value: obs.soundDetectionIsRunning)
    }

    var tabBody: some View {
        HStack(alignment: .top){
            TabItemView(tab: tabItems[0], selectedTab: $selectedTab, animation: animation)
            Spacer()
            ListenButton()
                .offset(y: -80)
            Spacer()
            TabItemView(tab: tabItems[1], selectedTab: $selectedTab, animation: animation)
        }
        .padding(.horizontal, 8)
        .padding(.top, 14)
        .frame(height: 88, alignment: .top)
        .background(.ultraThinMaterial, in: TabShape(holeWidth: 50, holeHeight: 50))
        .strokeStyleShape(shape: TabShape(holeWidth: 50, holeHeight: 50))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
            .environmentObject(dev.streamObs)
            .environmentObject(dev.visualObs)
            .environmentObject(dev.store)
    }
}
