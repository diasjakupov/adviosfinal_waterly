//
//  TaskRepository.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//


import CoreData
import Foundation

protocol TaskRepository {
    func add(_ task: TaskModel) async throws
    func categories() async throws -> [String]
    func updateStatus(id: UUID, to status: TaskStatus) async throws
}
