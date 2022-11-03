//
//  SearchStoreSpy.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 03/11/2022.
//

import Foundation
import KJVSearch

class SearchStoreSpy: SearchStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCachedSearch
        case insert([LocalSearchItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    func deleteCachedSearch(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedSearch)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [LocalSearchItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
}
