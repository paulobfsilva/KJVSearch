//
//  KJVSearchResultsCacheIntegrationTests.swift
//  KJVSearchResultsCacheIntegrationTests
//
//  Created by Paulo Silva on 07/11/2022.
//

import KJVSearch
import XCTest

class KJVSearchResultsCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation (description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(searchResults) :
                XCTAssertEqual (searchResults, [], "Expected empty feed")
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalSearchLoader {
        let storeBundle = Bundle( for: CoreDataSearchStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataSearchStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalSearchLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL () -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory ( ) -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
