//
//  IdentifiableDate.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import Foundation

struct IdentifiableDate: Identifiable, Equatable {
    let id: Date
    var date: Date { id }
    init(_ date: Date) { self.id = date }
} 