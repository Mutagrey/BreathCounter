//
//  TabItemView.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 28.01.2023.
//

import SwiftUI

struct TabItemView: View{

    let tab: TabItem
    @Binding var selectedTab: Tab
    var animation: Namespace.ID
    
    var body: some View{
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                selectedTab = tab.tab
            }
        } label: {
            VStack(spacing: 0.0){
                Image(systemName: tab.icon)
                    .resizable()
                    .scaledToFit()
                    .symbolVariant(selectedTab == tab.tab ? .fill : .none)
                    .font(.headline.bold())
                    .frame(width: 80, height: 20)
                    .padding()
                if tab.text.count > 0 {
                    Text(tab.text)
                        .font(.caption2)
                        .lineLimit(1)
                        .padding(.bottom, 8)
                }
                if selectedTab == tab.tab {
                    Capsule().fill(tab.color)
                        .frame(width: 5, height: 5)
                        .frame(maxWidth: .infinity)
                        .matchedGeometryEffect(id: "top", in: animation)
                } else {
                    Capsule().fill(.clear)
                        .frame(width: 5, height: 5)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(selectedTab == tab.tab ? .primary : .secondary)
    }
}

struct TabItemView_Previews: PreviewProvider {
    @Namespace static var animation
    static var previews: some View {
        TabItemView(tab: .init(text: "Tab", icon: "house", tab: .home, color: .indigo), selectedTab: .constant(.home), animation: animation)
    }
}
