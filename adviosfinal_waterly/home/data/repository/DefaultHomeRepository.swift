//
//  CoreDataHomeRepository.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//


import CoreData
import Combine

enum RepositoryError: Error {
    case fetchFailed(Error)
    case saveFailed(Error)
}

final class DefaultHomeRepository: HomeRepository {
    private let ctx: NSManagedObjectContext
    public init(ctx: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.ctx = ctx
    }
    
    
    func taskStream() -> AsyncThrowingStream<[TaskModel], Error> {
        AsyncThrowingStream { continuation in
            func sendUpdate() {
                Task {
                    do {
                        let tasks = try await fetch()
                        continuation.yield(tasks)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
            sendUpdate()
            let token = NotificationCenter.default.addObserver(
                forName: .NSManagedObjectContextDidSave,
                object: ctx,
                queue: nil
            ) { _ in sendUpdate() }
            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(token)
            }
        }
    }
    
    func fetch() async throws -> [TaskModel] {
        try await ctx.perform { [self] in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "date", ascending: true),
                NSSortDescriptor(key: "startTime", ascending: true)
            ]
            do {
                let entities = try ctx.fetch(request)
                return entities.compactMap(TaskModel.init(entity:))
            } catch {
                throw RepositoryError.fetchFailed(error)
            }
        }
    }
    
    func updateStatus(id: UUID, to s: TaskStatus) async throws {
        try await ctx.perform { [self] in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            do {
                guard let obj = try ctx.fetch(request).first else {
                    throw RepositoryError.saveFailed(NSError(
                        domain: "DefaultHomeRepository",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Task not found"]
                    ))
                }
                obj.status = s.rawValue
                do {
                    try ctx.save()
                } catch {
                    throw RepositoryError.saveFailed(error)
                }
            } catch {
                throw RepositoryError.saveFailed(error)
            }
        }
    }
}


private extension TaskModel {
    init?(entity e: TaskEntity) {
        guard
            let title = e.title,
            let date  = e.date,
            let start = e.startTime,
            let end   = e.endTime
        else { return nil }
        
        self.init(title: title,
                  date:  date,
                  startTime: start,
                  endTime:   end,
                  notes: e.notes ?? "",
                  category: e.category,
                  repeatRule: RepeatRule(rawValue: e.repeatRaw ?? "") ?? .none,
                  status: TaskStatus(rawValue: e.status ?? "") ?? .created
        )
        self.id = e.id ?? UUID()
    }
}
