//
//  Tab.swift
//  DesignCodeiOS15
//
//  Created by Sergey Petrov on 16.01.2023.
//

import SwiftUI

struct TabItem: Identifiable {
    var id = UUID()
    var text: String
    var icon: String
    var tab: Tab
    var color: Color
}

enum Tab: String {
    case home
    case sessions
}


