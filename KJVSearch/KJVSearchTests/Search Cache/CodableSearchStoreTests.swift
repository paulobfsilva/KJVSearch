//
//  CodableSearchStoreTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 04/11/2022.
//

import KJVSearch
import XCTest

class CodableSearchStore {
    
    private struct Cache: Codable {
        let searchResults: [CodableSearchItem]
        let timestamp: Date
        
        var localSearchResults: [LocalSearchItem] {
            return searchResults.map { $0.local }
        }
    }
    
    private struct CodableSearchItem: Codable {
        private let sampleId: String
        private let distance: Double
        private let externalId: String
        private let data: String
        
        init(_ searchResults: LocalSearchItem) {
            sampleId = searchResults.sampleId
            distance = searchResults.distance
            externalId = searchResults.externalId
            data = searchResults.data
        }
        
        var local: LocalSearchItem {
            return LocalSearchItem(sampleId: sampleId, distance: distance, externalId: externalId, data: data)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping SearchStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(results: cache.localSearchResults, timestamp: cache.timestamp))
    }
    
    func insert(_ items: [LocalSearchItem], timestamp: Date, completion: @escaping SearchStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(searchResults: items.map(CodableSearchItem.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableSearchStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let searchResults = uniqueItems().local
        let timestamp = Date()
        
        insert((searchResults, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(results: searchResults, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let searchResults = uniqueItems().local
        let timestamp = Date()
        
        insert((searchResults, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(results: searchResults, timestamp: timestamp))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableSearchStore {
        let sut = CodableSearchStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ cache: (results: [LocalSearchItem], timestamp: Date), to sut: CodableSearchStore) {
        let exp = expectation (description: "Wait for cache insertion")
        sut.insert(cache.results, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill ()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableSearchStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect (sut, toRetrieve: expectedResult, file: file, line: line)
        expect (sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableSearchStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
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
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }
}
