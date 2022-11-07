//
//  XCTestCase+SearchStoreSpecs.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 07/11/2022.
//

import KJVSearch
import XCTest

extension SearchStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (results: [LocalSearchItem], timestamp: Date), to sut: SearchStore) -> Error?{
        let exp = expectation (description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.results, timestamp: cache.timestamp) { receivedInsertionError in
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
