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
    typealias RetrievalCompletion = (Error?) -> Void
    
    func deleteCachedSearch(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalSearchItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
