//
//  SearchStore.swift
//  KJVSearch
//
//  Created by Paulo Silva on 02/11/2022.
//

import Foundation

public protocol SearchStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedSearch(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalSearchItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalSearchItem: Equatable, Decodable {
    public let sampleId: String
    public let distance: Double
    public let externalId: String
    public let data: String
    
    public init(sampleId: String, distance: Double, externalId: String, data: String) {
        self.sampleId = sampleId
        self.distance = distance
        self.externalId = externalId
        self.data = data
    }
}
