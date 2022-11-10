//
//  CacheSearchUseCaseTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 02/11/2022.
//

import KJVSearch
import XCTest

class CacheSearchUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(uniqueItems().models, query: anyQuery()) {_ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCachedSearch])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        
        sut.save(uniqueItems().models, query: anyQuery()) {_ in }
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedSearch])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = uniqueItems()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items.models, query: anyQuery()) {_ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedSearch, .insert(items.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyError()
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = SearchStoreSpy()
        var sut: LocalSearchLoader? = LocalSearchLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalSearchLoader.SaveResult]()
        sut?.save(uniqueItems().models, query: anyQuery()) { receivedResults.append($0) }
        // remove the reference to the SUT after it has been deallocated
        sut = nil
        store.completeDeletion(with: anyError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = SearchStoreSpy()
        var sut: LocalSearchLoader? = LocalSearchLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalSearchLoader.SaveResult]()
        sut?.save(uniqueItems().models, query: anyQuery()) { receivedResults.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalSearchLoader, store: SearchStoreSpy) {
        let store = SearchStoreSpy()
        let sut = LocalSearchLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalSearchLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(uniqueItems().models, query: anyQuery()) { saveResult in
            switch saveResult {
            case .success:
                receivedError = nil
            case let .failure(error):
                receivedError = error
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func anyQuery() -> String {
        return "any-text-query"
    }
}
