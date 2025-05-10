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
            if let error {
                // Log error and notify the app instead of crashing
                print("CoreData error: \(error)")
                // Optionally, post a notification or call a delegate to inform the UI
            }
        }
        return container
    }()
}
