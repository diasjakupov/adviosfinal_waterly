//
//  DayStub.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 07.05.2025.
//

import SwiftUI

struct DayStub: Identifiable {
    let id = UUID()
    let date: Date
    let groups: [(name: String, count: Int)]
}
