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
    
    init(store: SearchStore) {
        self.store = store
    }
    
    func save(_ items: [SearchItem]) {
        store.deleteCachedSearch { [unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
}

class SearchStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCachedSearchCallCount = 0
    var insertCallCount = 0
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedSearch(completion: @escaping DeletionCompletion) {
        deleteCachedSearchCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [SearchItem]) {
        insertCallCount += 1
    }
}

class CacheSearchUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedSearchCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items)
        XCTAssertEqual(store.deleteCachedSearchCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalSearchLoader, store: SearchStore) {
        let store = SearchStore()
        let sut = LocalSearchLoader(store: store)
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
