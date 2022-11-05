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
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "search-results.store")
    
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
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "search-results.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "search-results.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let searchResults = uniqueItems().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(searchResults, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected search results to be inserted successfully")
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedResults, retrievedTimestamp):
                    XCTAssertEqual(retrievedResults, searchResults)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                default:
                    XCTFail("Expected found result with search results \(searchResults) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableSearchStore {
        let sut = CodableSearchStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
