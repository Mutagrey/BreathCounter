//
//  AppConfig.swift
//  BreathCounter
//
//  Created by Sergey Petrov on 04.02.2023.
//

import SwiftUI

final class AppConfig: ObservableObject {
    @AppStorage("confidence") var confidence: Double = 0.5
    @AppStorage("inferenceWindowSize") var inferenceWindowSize: Double = 1.5
    @AppStorage("overlapFactor") var overlapFactor: Double = 0.5
    @AppStorage("averageElementsCount") var averageElementsCount: Int = 5

    let identifiers: Set<String> = .init(["breathing", "nose_blowing", "sigh", "gasp"])
}
