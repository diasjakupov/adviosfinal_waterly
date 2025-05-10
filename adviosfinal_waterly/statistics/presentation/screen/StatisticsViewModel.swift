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
    @Published var error: String? = nil
    private let getStatisticsUseCase: GetStatisticsUseCase
    
    init(getStatisticsUseCase: GetStatisticsUseCase) {
        self.getStatisticsUseCase = getStatisticsUseCase
    }
    
    func load() {
        Task {
            do {
                self.statistics = try await getStatisticsUseCase.execute()
                self.error = nil
            } catch {
                self.error = error.localizedDescription.isEmpty ? "Failed to load statistics. Please try again." : error.localizedDescription
            }
        }
    }
} 
