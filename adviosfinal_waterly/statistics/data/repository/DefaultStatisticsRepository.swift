//
//  DefaultStatisticsRepository.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import CoreData

final class DefaultStatisticsRepository: StatisticsRepository {
    
    func getStatistics() async throws -> StatisticsModel {
        let ctx = CoreDataStack.shared.viewContext
        return try await ctx.perform {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            let tasks = try ctx.fetch(request)
            let doneCount = tasks.filter { $0.status == TaskStatus.done.rawValue }.count
            let missedCount = tasks.filter { $0.status != TaskStatus.done.rawValue }.count
            return StatisticsModel(done: doneCount, missed: missedCount)
        }
    }
}
