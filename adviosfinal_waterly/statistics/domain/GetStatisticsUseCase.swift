//
//  GetStatisticsUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import Foundation

final class GetStatisticsUseCase {
    private let repository: StatisticsRepository
    init(repository: StatisticsRepository) {
        self.repository = repository
    }
    func execute() async throws -> StatisticsModel {
        try await repository.getStatistics()
    }
} 
