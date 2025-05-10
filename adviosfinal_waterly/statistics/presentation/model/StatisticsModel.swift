//
//  StatisticsModel.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import Foundation

struct StatisticsModel {
    let done: Int
    let missed: Int
    var total: Int { done + missed }
} 