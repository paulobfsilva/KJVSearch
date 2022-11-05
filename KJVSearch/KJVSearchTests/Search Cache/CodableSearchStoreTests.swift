//
//  CodableSearchStoreTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 04/11/2022.
//

import KJVSearch
import XCTest

class CodableSearchStore {
    func retrieve(completion: @escaping SearchStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableSearchStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableSearchStore()
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
}
