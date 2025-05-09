//
//  GetCategoriesUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation

final class GetCategoriesUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [String] {
        try await repository.categories()
    }
} 
