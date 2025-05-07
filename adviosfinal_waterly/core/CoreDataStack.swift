//
//  CoreDataStack.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//


import CoreData

enum CoreDataStack {
    static let shared: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "adviosfinal_waterly")
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData error \(error)") }
        }
        return container
    }()
}
