//
//  DefaultTaskRepository.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//


import CoreData
import Foundation
import UserNotifications


final class DefaultTaskRepository: TaskRepository {
    
    enum TaskRepositoryError: Error {
        case notFound
        case saveFailed(Error)
        case fetchFailed(Error)
    }
    
    private let ctx: NSManagedObjectContext
    init(ctx: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.ctx = ctx
    }
    
}

// MARK: - Add
extension DefaultTaskRepository {
    func add(_ task: TaskModel) async throws {
        try await ctx.perform {
            let entity = TaskEntity(context: self.ctx)
            self.apply(task, to: entity)
            try self.saveContext()
        }
    }
}

// MARK: - Update
extension DefaultTaskRepository {
    func update(_ task: TaskModel) async throws {
        try await ctx.perform {
            guard let entity = try self.fetchEntity(by: task.id) else {
                throw TaskRepositoryError.notFound
            }
            self.apply(task, to: entity)
            try self.saveContext()
        }
    }
    func updateStatus(id: UUID, to status: TaskStatus) async throws {
        try await ctx.perform {
            guard let entity = try self.fetchEntity(by: id) else {
                throw TaskRepositoryError.notFound
            }
            entity.status = status.rawValue
            try self.saveContext()
            if status == .done {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
            }
        }
    }
}

// MARK: - Delete
extension DefaultTaskRepository {
    func delete(_ task: TaskModel) async throws {
        try await ctx.perform { [self] in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            if task.repeatRule == .none {
                request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            } else {
                request.predicate = NSPredicate(format: "title == %@ AND repeatRaw == %@", task.title, task.repeatRule.rawValue)
            }
            let entities = try ctx.fetch(request)
            guard !entities.isEmpty else {
                throw TaskRepositoryError.notFound
            }
            for entity in entities {
                ctx.delete(entity)
            }
            try self.saveContext()
        }
    }
}

// MARK: - Fetch
extension DefaultTaskRepository {
    func categories() async throws -> [String] {
        try await ctx.perform {
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
}

// MARK: - Mapping & Helpers
private extension DefaultTaskRepository {
    func fetchEntity(by id: UUID) throws -> TaskEntity? {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try ctx.fetch(request).first
    }
    func apply(_ task: TaskModel, to entity: TaskEntity) {
        entity.id        = task.id
        entity.title     = task.title
        entity.date      = task.date
        entity.startTime = task.startTime
        entity.endTime   = task.endTime
        entity.notes     = task.notes
        entity.category  = task.category
        entity.repeatRaw = task.repeatRule.rawValue
        entity.status    = task.status.rawValue
        entity.eventId   = task.eventId
        if let eventIds = task.eventIds {
            entity.eventIds = eventIds as NSArray
        } else {
            entity.eventIds = nil
        }
    }
    func saveContext() throws {
        do {
            try ctx.save()
        } catch {
            throw TaskRepositoryError.saveFailed(error)
        }
    }
}

// MARK: - TaskModel Mapping
extension TaskModel {
    init?(entity e: TaskEntity) {
        guard
            let title = e.title,
            let date  = e.date,
            let start = e.startTime,
            let end   = e.endTime
        else { return nil }
        self.init(
            id: e.id ?? UUID(),
            title: title,
            date: date,
            startTime: start,
            endTime: end,
            notes: e.notes ?? "",
            category: e.category,
            repeatRule: RepeatRule(rawValue: e.repeatRaw ?? "") ?? .none,
            status: TaskStatus(rawValue: e.status ?? "") ?? .created,
            eventId: e.eventId,
            eventIds: e.eventIds as? [String]
        )
    }
}
