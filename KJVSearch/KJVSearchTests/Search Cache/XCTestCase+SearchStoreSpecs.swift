//
//  XCTestCase+SearchStoreSpecs.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 07/11/2022.
//

import KJVSearch
import XCTest

extension SearchStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: SearchStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: SearchStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: SearchStore, file: StaticString = #file, line: UInt = #line) {
        let searchResults = uniqueItems().local
        let timestamp = Date()
        insert((searchResults, timestamp), query: anyQuery(), to: sut)
        expect(sut, toRetrieve: .found(results: searchResults, timestamp: timestamp))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: SearchStore, file: StaticString = #file, line: UInt = #line) {
        let searchResults = uniqueItems().local
        let timestamp = Date()
        
        insert((searchResults, timestamp), query: anyQuery(), to: sut)
        expect(sut, toRetrieveTwice: .found(results: searchResults, timestamp: timestamp))
    }
    
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: SearchStore, for storeURL: URL) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: SearchStore, for storeURL: URL) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyError()))
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: SearchStore) {
        let insertionError = insert ((uniqueItems().local, Date()), query: anyQuery(), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: SearchStore) {
        insert((uniqueItems().local, Date()), query: anyQuery(), to: sut)
        let insertionError =
        insert ((uniqueItems().local, Date()), query: anyQuery(), to: sut)
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: SearchStore) {
        insert((uniqueItems().local, Date()), query: anyQuery(), to: sut)
        
        let latestResult = uniqueItems().local
        let latestTimestamp = Date()
        insert((latestResult, latestTimestamp), query: anyQuery(), to: sut)
        
        expect(sut, toRetrieve: .found(results: latestResult, timestamp: latestTimestamp))
    }
    
    func assertThatInsertDeliversErrorOnInsertionError(on sut: SearchStore) {
        let results = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((results, timestamp), query: anyQuery(), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: SearchStore) {
        let results = uniqueItems().local
        let timestamp = Date()
        
        insert((results, timestamp), query: anyQuery(), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: SearchStore) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: SearchStore) {
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: SearchStore) {
        insert((uniqueItems().local, Date()), query: anyQuery(), to: sut)
        let deletionError = deleteCache(from: sut)
        XCTAssertNil (deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: SearchStore) {
        insert((uniqueItems().local, Date()), query: anyQuery(), to: sut)
        
        deleteCache(from: sut)
        
        expect (sut, toRetrieve: .empty)
    }
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: SearchStore) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: SearchStore) {
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func assertThatSideEffectsRunSerially(on sut: SearchStore) {
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueItems().local, timestamp: Date(), query: anyQuery()) { _ in
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedSearch { _ in
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueItems().local, timestamp: Date(), query: anyQuery()) { _ in
            op3.fulfill()
        }
        
        wait(for: [op1,op2, op3], timeout: 5.0, enforceOrder: true)
    }
    
    @discardableResult
    func insert(_ cache: (results: [LocalSearchItem], timestamp: Date), query: String, to sut: SearchStore) -> Error?{
        let exp = expectation (description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.results, timestamp: cache.timestamp, query: anyQuery()) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill ()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: SearchStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedSearch { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: SearchStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect (sut, toRetrieve: expectedResult, file: file, line: line)
        expect (sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: SearchStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedResult, expectedTimestamp), .found(retrievedResult, retrievedTimestamp)):
                XCTAssertEqual(retrievedResult, expectedResult, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
