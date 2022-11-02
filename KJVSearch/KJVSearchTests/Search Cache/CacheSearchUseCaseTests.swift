//
//  CacheSearchUseCaseTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 02/11/2022.
//

import KJVSearch
import XCTest

class LocalSearchLoader {
    private let store: SearchStore
    private let currentDate: () -> Date
    
    init(store: SearchStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [SearchItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedSearch { [unowned self] error in
            completion(error)
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class SearchStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    enum ReceivedMessage: Equatable {
        case deleteCachedSearch
        case insert([SearchItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
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
    
    func insert(_ items: [SearchItem], timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
}

class CacheSearchUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items) {_ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCachedSearch])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        
        sut.save(items) {_ in }
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedSearch])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items) {_ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedSearch, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalSearchLoader, store: SearchStore) {
        let store = SearchStore()
        let sut = LocalSearchLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> SearchItem {
        // sampleId is what makes a SearchItem unique
        return SearchItem(sampleId: UUID().uuidString, distance: 0.5, externalId: "externalId", data: "data")
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
