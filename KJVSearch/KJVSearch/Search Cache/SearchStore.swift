//
//  SearchStore.swift
//  KJVSearch
//
//  Created by Paulo Silva on 02/11/2022.
//

import Foundation

public typealias CachedSearchResults = (results:[LocalSearchItem], timestamp: Date)


public protocol SearchStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    typealias RetrievalResult = Result<CachedSearchResults?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedSearch(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ items: [LocalSearchItem], timestamp: Date, query: String, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
