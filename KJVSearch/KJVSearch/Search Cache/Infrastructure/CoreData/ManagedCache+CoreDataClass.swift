//
//  ManagedCache+CoreDataClass.swift
//  KJVSearch
//
//  Created by Paulo Silva on 07/11/2022.
//
//

import Foundation
import CoreData

@objc(ManagedCache)
internal final class ManagedCache: NSManagedObject {
    @NSManaged internal var timestamp: Date
    @NSManaged internal var query: String
    @NSManaged internal var results: NSOrderedSet
    
    var localSearchResults: [LocalSearchItem] {
        results.compactMap { ($0 as? ManagedSearchResult)?.local }
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}
