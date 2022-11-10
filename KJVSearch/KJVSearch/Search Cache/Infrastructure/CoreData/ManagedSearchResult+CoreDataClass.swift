//
//  ManagedSearchResult+CoreDataClass.swift
//  KJVSearch
//
//  Created by Paulo Silva on 07/11/2022.
//
//

import Foundation
import CoreData

@objc(ManagedSearchResult)
internal final class ManagedSearchResult: NSManagedObject {
    @NSManaged internal var sampleId: String
    @NSManaged internal var externalId: String
    @NSManaged internal var distance: Double
    @NSManaged internal var data: String
    @NSManaged internal var cache: ManagedCache
    
    var local: LocalSearchItem {
        LocalSearchItem(sampleId: sampleId, distance: distance, externalId: externalId, data: data)
    }
    
    static func results(from localSearchResults: [LocalSearchItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array: localSearchResults.map { local in
            let managed = ManagedSearchResult(context: context)
            managed.sampleId = local.sampleId
            managed.externalId = local.externalId
            managed.distance = local.distance
            managed.data = local.data
            return managed
        })
    }
}
