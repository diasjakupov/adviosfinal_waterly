//
//  StatisticsViewModel.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import SwiftUI


@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var statistics: StatisticsModel? = nil
    private let getStatisticsUseCase: GetStatisticsUseCase
    
    init(getStatisticsUseCase: GetStatisticsUseCase) {
        self.getStatisticsUseCase = getStatisticsUseCase
    }
    
    func load() {
        Task {
            self.statistics = try? await getStatisticsUseCase.execute()
        }
    }
} 
