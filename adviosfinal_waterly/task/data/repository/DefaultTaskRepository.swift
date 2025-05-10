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
            e.status    = task.status.rawValue
            e.eventId   = task.eventId
            if let eventIds = task.eventIds {
                e.eventIds = eventIds as NSArray
            } else {
                e.eventIds = nil
            }
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
            guard let obj = try ctx.fetch(r).first else {
                throw TaskRepositoryError.notFound
            }
            obj.status = s.rawValue
            do {
                try ctx.save()
            } catch {
                throw TaskRepositoryError.saveFailed(error)
            }
            if s == .done {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
            }
        }
    }
    
    func update(_ task: TaskModel) async throws {
        try await ctx.perform { [self] in
            let r: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            r.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            guard let obj = try ctx.fetch(r).first else {
                throw TaskRepositoryError.notFound
            }
            obj.title     = task.title
            obj.date      = task.date
            obj.startTime = task.startTime
            obj.endTime   = task.endTime
            obj.notes     = task.notes
            obj.category  = task.category
            obj.repeatRaw = task.repeatRule.rawValue
            obj.status    = task.status.rawValue
            obj.eventId   = task.eventId
            if let eventIds = task.eventIds {
                obj.eventIds = eventIds as NSArray
            } else {
                obj.eventIds = nil
            }
            do {
                try ctx.save()
            } catch {
                throw TaskRepositoryError.saveFailed(error)
            }
        }
    }

    func delete(_ task: TaskModel) async throws {
        try await ctx.perform { [self] in
            let r: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            if task.repeatRule == .none {
                r.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            } else {
                // For repeated tasks, delete all with the same title and repeat rule
                r.predicate = NSPredicate(format: "title == %@ AND repeatRaw == %@", task.title, task.repeatRule.rawValue)
            }
            let objs = try ctx.fetch(r)
            if objs.isEmpty {
                throw TaskRepositoryError.notFound
            }
            for obj in objs {
                ctx.delete(obj)
            }
            do {
                try ctx.save()
            } catch {
                throw TaskRepositoryError.saveFailed(error)
            }
        }
    }
    
}

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
