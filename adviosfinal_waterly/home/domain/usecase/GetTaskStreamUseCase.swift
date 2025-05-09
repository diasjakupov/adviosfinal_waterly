//
//  GetTaskStreamUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation

final class GetTaskStreamUseCase {
    private let repository: HomeRepository
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    func execute() -> AsyncThrowingStream<[TaskModel], Error> {
        repository.taskStream()
    }
} 
