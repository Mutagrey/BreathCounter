//
//  YogaDataServiceProtocol.swift
//  YogaBreath
//
//  Created by Sergey Petrov on 18.01.2023.
//

import SwiftUI
import Combine

protocol DataServiceProtocol  {
    @Sendable func loadData() async throws -> [Yoga]
    func save(_ yoga: Yoga) async throws
    func remove(_ yoga: Yoga) async throws
}
