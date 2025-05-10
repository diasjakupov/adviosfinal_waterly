//
//  StatisticsRepository.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import Foundation

protocol StatisticsRepository{
    func getStatistics() async throws -> StatisticsModel
}
