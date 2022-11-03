//
//  LoadSearchFromCacheUseCaseTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 03/11/2022.
//

import KJVSearch
import XCTest

class LoadSearchFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyError()
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoSearchResultsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedSearchResultsOnLessThan30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let lessThan30DaysOldTimestamp = fixedCurrentDate.adding(days: -30).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(results.models)) {
            store.completeRetrieval(with: results.local, timestamp: lessThan30DaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoSearchResultsOn30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let thirtyDaysOldTimestamp = fixedCurrentDate.adding(days: -30)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: results.local, timestamp: thirtyDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoSearchResultsOnMoreThan30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let moreThan30DaysOldTimestamp = fixedCurrentDate.adding(days: -30).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: results.local, timestamp: moreThan30DaysOldTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnLessThan30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let lessThan30DaysOldTimestamp = fixedCurrentDate.adding(days: -30).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: results.local, timestamp: lessThan30DaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOn30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let thirtyDaysOldTimestamp = fixedCurrentDate.adding(days: -30)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: results.local, timestamp: thirtyDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnMoreThan30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let moreThan30DaysOldTimestamp = fixedCurrentDate.adding(days: -30).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: results.local, timestamp: moreThan30DaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = SearchStoreSpy()
        var sut: LocalSearchLoader? = LocalSearchLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalSearchLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        store.completeRetrievalWithEmptyCache()
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
    
    private func expect(_ sut: LocalSearchLoader, toCompleteWith expectedResult: LocalSearchLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}
