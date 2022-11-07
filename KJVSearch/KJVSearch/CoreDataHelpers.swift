//
//  CoreDataHelpers.swift
//  KJVSearch
//
//  Created by Paulo Silva on 07/11/2022.
//

import CoreData

extension NSPersistentContainer {
    static func load(modelName: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let model = NSManagedObjectModel(name: modelName, in: bundle)!
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        return container
        
    }
}

extension NSManagedObjectModel {
    convenience init?(name: String, in bundle: Bundle) {
        guard let momd = bundle.url(forResource: name, withExtension: "momd") else {
            return nil
        }
        self.init(contentsOf: momd)
    }
}
