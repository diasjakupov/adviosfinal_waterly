//
//  HomeRepository.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//

import SwiftUI

protocol HomeRepository {
    func taskStream() -> AsyncThrowingStream<[TaskModel], Error>
    func updateStatus(id: UUID, to status: TaskStatus) async throws
}
