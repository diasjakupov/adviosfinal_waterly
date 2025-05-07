//
//  DefaultTaskRepository.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//


import CoreData
import Foundation


final class DefaultTaskRepository: TaskRepository {
    
    private let ctx: NSManagedObjectContext
    init(ctx: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.ctx = ctx
    }
    
    
    func add(_ task: TaskModel) async throws {
        try await ctx.perform {
            let e = TaskEntity(context: self.ctx)
            e.id        = task.id
            e.title     = task.title
            e.date      = task.date
            e.startTime = task.startTime
            e.endTime   = task.endTime
            e.notes     = task.notes
            e.category  = task.category
            e.repeatRaw = task.repeatRule.rawValue
            try self.ctx.save()
        }
    }
    
    
    func categories() async throws -> [String] {
        try await self.ctx.perform {
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
            req.resultType             = .dictionaryResultType
            req.propertiesToFetch      = ["category"]
            req.returnsDistinctResults = true
            req.returnsObjectsAsFaults = false
            let dicts = try self.ctx.fetch(req) as! [[String : Any]]
            let names = dicts
                        .compactMap { $0["category"] as? String }
                        .filter { !$0.isEmpty }
                        .sorted()
            return names
        }
    }
    
    func updateStatus(id: UUID, to s: TaskStatus) async throws {
        try await ctx.perform { [self] in
                let r: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                r.predicate = NSPredicate(format:"id == %@", id as CVarArg)
                guard let obj = try ctx.fetch(r).first else { return }
                obj.status = s.rawValue
                try ctx.save()
            }
        }
}
