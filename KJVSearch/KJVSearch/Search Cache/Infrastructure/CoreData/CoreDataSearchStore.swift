//
//  CoreDataSearchStore.swift
//  KJVSearch
//
//  Created by Paulo Silva on 07/11/2022.
//

import CoreData

public final class CoreDataSearchStore: SearchStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "SearchStoreDataModel", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    return CachedSearchResults(results: $0.localSearchResults, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ items: [KJVSearch.LocalSearchItem], timestamp: Date, query: String, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.query = query
                managedCache.results = ManagedSearchResult.results(from: items, in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedSearch(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
        
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
}

