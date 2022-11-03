//
//  ValidateSearchCacheUseCaseTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 03/11/2022.
//

import KJVSearch
import XCTest

class ValidateSearchCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyError())
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedSearch])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteLessThan30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let lessThan30DaysOldTimestamp = fixedCurrentDate.adding(days: -30).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: results.local, timestamp: lessThan30DaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletes30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let thirtyDaysOldTimestamp = fixedCurrentDate.adding(days: -30)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: results.local, timestamp: thirtyDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedSearch])
    }
    
    func test_validateCache_deletesMoreThan30DaysOldCache() {
        let results = uniqueItems()
        let fixedCurrentDate = Date()
        let moreThan30DaysOldTimestamp = fixedCurrentDate.adding(days: -30).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: results.local, timestamp: moreThan30DaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedSearch])
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalSearchLoader, store: SearchStoreSpy) {
        let store = SearchStoreSpy()
        let sut = LocalSearchLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
